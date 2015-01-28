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

- init {
    self = [super init];

    if ( self != nil) {
        manager = [[AFHTTPRequestOperationManager alloc] init];

        MNHtmlSerializer *htmlSerializer = [MNHtmlSerializer serializer];
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
        AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
        AFXMLParserResponseSerializer *xmlSerializer = [AFXMLParserResponseSerializer serializer];
        AFCompoundResponseSerializer *compoundSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer, htmlSerializer, xmlSerializer]];
        manager.responseSerializer = compoundSerializer;

        [manager.operationQueue setMaxConcurrentOperationCount:10];

        NSLog(@"current set of acceptable content types: %@", manager.responseSerializer.acceptableContentTypes);
    }

    return self;
}

- (BOOL)validateURL : (NSString *)data {
    NSURL *testURL = [NSURL URLWithString:data];
    BOOL supportedScheme = [[testURL scheme] isEqualToString:@"http"] || [[testURL scheme] isEqualToString:@"https"];
    return (testURL != nil) && supportedScheme && ([testURL host]);
}


- (BOOL) getURL: (NSString *)url
     parameters: (NSArray *)parameters
        success: (MNURLInspectorResultBlock)successBlock
        failure: (MNURLInspectorFailureBlock)failureBlock
{

    return [self getURL:url parameters:parameters success:successBlock failure:failureBlock redirect:nil];
}


- (BOOL) getURL: (NSString *)url
     parameters: (NSArray *)parameters
        success: (MNURLInspectorResultBlock)successBlock
        failure: (MNURLInspectorFailureBlock)failureBlock
       redirect: (MNURLInspectorRedirectBlock)redirectBlock
{
    if (![self validateURL:url]) {
        return NO;
    }

    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:parameters error:nil];
    AFHTTPRequestOperation *requestOperation = [self HTTPRequestOperationWithRequest:request success:successBlock failure:failureBlock];

    requestOperation.responseSerializer = manager.responseSerializer;

    if (redirectBlock ) {
        [requestOperation setRedirectResponseBlock: redirectBlock];
    }
    
    [manager.operationQueue addOperation:requestOperation];

    return YES;
}






@end