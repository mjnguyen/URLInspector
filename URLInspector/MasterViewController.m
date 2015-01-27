//
//  MasterViewController.m
//  URLInspector
//
//  Created by Michael Nguyen on 1/25/15.
//
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "UrlResponseInfo.h"
#import "RequestEvent.h"
#import "TSMessage.h"

@interface MasterViewController () {
    NSMutableArray *listOfItems;
    MNURLRequestManager *manager;
}

@end

@implementation MasterViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // initialize the AFNetworkManager
    manager = [MNURLRequestManager sharedInstance];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.resultsTableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[segue destinationViewController];
        [controller setDetailItem:object];
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RequestEvent *event = (RequestEvent *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *displayInfo = [NSString stringWithFormat:@"Fetch %ld: HTTP %@, %3.0f ms, %ld bytes", (long)indexPath.row, event.statusCode, [[event elapsedTime] doubleValue] * 1000 , (long)[event.responseSize integerValue] ];
    cell.textLabel.text = displayInfo;
}


#pragma mark - UITextFieldDelegates

// prevent text field from adding a new line
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}


#pragma mark - URL Processing

- (void)enqueueURLRequests : (NSString *)urlToEnqueue {

    __block NSString *UUID = [self createNewObject: urlToEnqueue];

    [manager getURL:urlToEnqueue parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // upon success add request/response to db
        UrlResponseInfo *responseInfo = [[UrlResponseInfo alloc] initWithHttpOperation: operation requestId:UUID];
        [self updateObject: UUID withData: responseInfo];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // upon failure
        NSLog(@"Request failed!: %@", [error localizedDescription]);
        UrlResponseInfo *responseInfo = [[UrlResponseInfo alloc] initWithHttpOperation: operation requestId:UUID];

        // perhaps do something extra with errors.
        switch ([error code]) {
            case -1001:
                // 404 error
                NSLog(@"page not found for %@", responseInfo.requestURI);
                break;
            case -1003:
                // Failed DNS lookup
                NSLog(@"Failed to find hostname for %@", responseInfo.requestURI);
                break;
            case -1011:
                // 500 error
                NSLog(@"Server error with URI %@", responseInfo.requestURI);
                break;

            default:
                break;
        }

        [self updateObject: UUID withData: responseInfo];

    } ];
}


- (IBAction)submitURLForProcessing: (id)sender {
    // GO button was pressed.
    // 1. check to make sure URL entered is valid
    // 2. clear the db of old results
    // 3. submit URL to controller to loop through 'count' calls

    [self.view endEditing:YES];

    if ( [manager validateURL: [self.urlTextField text]]) {
        // clear the previous set of results

        [self clearAllRequestsWithCompletionBlock: ^(BOOL success) {
            for (int idx = 0; idx < [self.countTextField.text intValue]; idx++ ) {
                [self enqueueURLRequests: self.urlTextField.text];
            }
        }];
    }
    else {
        // alert user that input is invalid and focus on the offending field
        dispatch_async( dispatch_get_main_queue(), ^{
            [TSMessage showNotificationWithTitle:@"Input Error" subtitle:@"Please double check that you typed in the URL correctly. Perhaps you forgot to add 'http://' or 'https://'" type:TSMessageNotificationTypeError];
        });

    }

}


#pragma mark - Core Data Handlers

// clear out all the database of values.
// for the purposes of this demo, we want a clean slate for every new request.  Otherwise,
//  the db would grow very quickly.
//  The need for the completion block is to ensure that deletion happens before anything else.  We want to keep the deletion/addition
// of objects clean and orderly.
- (void)clearAllRequestsWithCompletionBlock:(MNGenericCompletionBlock)completionBlock {

    NSError *error;
    NSArray *matches = nil;
    NSString *entityName = NSStringFromClass([RequestEvent class]);
    NSFetchRequest *deleteAll = [NSFetchRequest fetchRequestWithEntityName:entityName];
    matches = [self.managedObjectContext executeFetchRequest:deleteAll error:&error];

    if ([matches count] > 0) {
        for (id obj in matches) {
            [_managedObjectContext deleteObject:obj];
        }

        [self.managedObjectContext save:&error];
    }

    completionBlock(YES);
}


// using the time the request was queued for retrieval as start time.
// if more in depth timing is required, the actual time the URL is requested can be used, this
// requires the use of notifications.  The controller would need to listen to AFNetworkingDidStartNotification and AFNetworkingOperationDidFinishNotification
// as is currently used by the AFNetworkingLogger.
// https://github.com/AFNetworking/AFHTTPRequestOperationLogger/blob/master/AFHTTPRequestOperationLogger.m

- (NSString *)createNewObject:(NSString *)url {
    // generate a new id for the request to track it.
    NSString *requestId = [[NSUUID UUID] UUIDString];

    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    [newManagedObject setValue:[NSDate date] forKey:@"startTime"];
    [newManagedObject setValue:url  forKey:@"url"];
    [newManagedObject setValue:requestId forKey:@"requestId"];

    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }


    return requestId;
}


// update the saved entity with new data
- (void)updateObject: (NSString *)requestid withData: (UrlResponseInfo *)data {
    // update the entity with the associated requestId with information from the response
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc = self.managedObjectContext;

    [request setEntity:[NSEntityDescription entityForName: NSStringFromClass([RequestEvent class]) inManagedObjectContext:moc]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"requestId == %@", data.requestId];

    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];

    // error handling code
    if (error != nil) {
        // if we can't find the entity, then we can just ignore the data coming in
        NSLog(@"Error updating the URL request (%@) %@", data.requestURI, [error localizedDescription]);
        error = nil;
    }

    RequestEvent *matchedEntity = [results firstObject];
    matchedEntity.responseString = [data responseString];
    matchedEntity.statusCode = [data statusCode];
    matchedEntity.endTime   = [data timestamp];
    matchedEntity.responseSize      = [data contentLength];

    // now update the db with the entity

    if (![moc save:&error]) {
        // error while saving... can't do much just move on.
        NSLog(@"Error while updating record! %@", [error localizedDescription]);
    }
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([RequestEvent class]) inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSPredicate *endTimeFilterPredicate = [NSPredicate predicateWithFormat:@"SELF.endTime > SELF.startTime"];
    [fetchRequest setPredicate:endTimeFilterPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"endTime" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.resultsTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.resultsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.resultsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.resultsTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.resultsTableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
