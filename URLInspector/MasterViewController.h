//
//  MasterViewController.h
//  URLInspector
//
//  Created by Michael Nguyen on 1/25/15.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MNURLRequestManager.h"

typedef void (^MNGenericCompletionBlock)(BOOL success);

@class DetailViewController;

@interface MasterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,
                                                UITextFieldDelegate,
                                                NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DetailViewController          *detailViewController;
@property (strong, nonatomic) IBOutlet UIButton             *goButton;
@property (strong, nonatomic) IBOutlet UITableView          *resultsTableView;
@property (strong, nonatomic) IBOutlet UITextField          *urlTextField;
@property (strong, nonatomic) IBOutlet UITextField          *countTextField;
@property (strong, nonatomic) IBOutlet UILabel              *urlLabel;
@property (strong, nonatomic) IBOutlet UILabel              *countLabel;

@property (strong, nonatomic) NSFetchedResultsController    *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext        *managedObjectContext;

@property (strong, nonatomic) MNURLRequestManager           *manager;

- (IBAction)submitURLForProcessing: (id)sender;

@end

