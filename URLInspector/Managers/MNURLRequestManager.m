    //
//  MNURLRequestManager.m
//  URLInspector
//
//  Created by Michael Nguyen on 1/25/15.
//
//

#import <Foundation/Foundation.h>
#import "MNURLRequestManager.h"

#import "MNHtmlSerializer.h"

@implementation MNURLRequestManager

@synthesize manager;

+(id)sharedInstance {
    static MNURLRequestManager *someSharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        someSharedInstance = [[self alloc] init];
    });

    return someSharedInstance;
}


- (BOOL)validateURL : (NSString *)data {
    NSURL *testURL = [NSURL URLWithString:data];

    return testURL != nil && ([testURL host]);
}


- init {
    self = [super init];

    if ( self != nil) {
        manager = [AFHTTPRequestOperationManager manager];

        MNHtmlSerializer *htmlSerializer = [MNHtmlSerializer serializer];
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
        AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
        AFXMLParserResponseSerializer *xmlSerializer = [AFXMLParserResponseSerializer serializer];
        AFCompoundResponseSerializer *compoundSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer, htmlSerializer, xmlSerializer]];
        manager.responseSerializer = compoundSerializer;

        [manager.operationQueue setMaxConcurrentOperationCount:10];

        NSLog(@"current set of acceptable content typtes: %@", manager.responseSerializer.acceptableContentTypes);
    }

    return self;
}

- (BOOL) getURL: (NSString *)url
     parameters: (NSArray *)parameters
        success: (MNURLInspectorResultBlock)successBlock
        failure: (MNURLInspectorFailureBlock)failureBlock
{

    return [self getURL:url parameters:parameters success:successBlock failure:failureBlock followRedirect:YES];
}


- (BOOL) getURL: (NSString *)url
     parameters: (NSArray *)parameters
        success: (MNURLInspectorResultBlock)successBlock
        failure: (MNURLInspectorFailureBlock)failureBlock
 followRedirect: (BOOL)followRedirect
{
    if (![self validateURL:url]) {
        return NO;
    }

    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:parameters error:nil];
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:successBlock failure:failureBlock];

    requestOperation.responseSerializer = manager.responseSerializer;
    __weak AFHTTPRequestOperation *weakRequestOperation = requestOperation;

    if (!followRedirect ) {
    [requestOperation setRedirectResponseBlock: ^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
        if (redirectResponse == nil) {
            return request;
        } else {
            NSLog(@"in redirect, blocking");
            [weakRequestOperation cancel];
            return nil;
        }
    }];

    }
    [manager.operationQueue addOperation:requestOperation];

    return YES;
}






@end