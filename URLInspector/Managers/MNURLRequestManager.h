//
//  MNURLRequestManager.h
//  URLInspector
//
//  Created by Michael Nguyen on 1/25/15.
//
//

#ifndef URLInspector_MNURLRequestManager_h
#define URLInspector_MNURLRequestManager_h

#import "AFNetworking.h"

typedef void (^MNURLInspectorResultBlock)(AFHTTPRequestOperation* operation, id responseObject);
typedef void (^MNURLInspectorFailureBlock)(AFHTTPRequestOperation  *operation, NSError *error);
typedef NSURLRequest* (^MNURLInspectorRedirectBlock)(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse);

@interface MNURLRequestManager : AFHTTPRequestOperationManager

+(id)sharedInstance;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

- (BOOL) getURL: (NSString *)url
     parameters: (NSArray *)params
        success: (MNURLInspectorResultBlock)successBlock
        failure: (MNURLInspectorFailureBlock)failureBlock
 followRedirect: (BOOL)followRedirect;

- (BOOL) getURL: (NSString *)url
     parameters: (NSArray *)params
        success: (MNURLInspectorResultBlock)successBlock
        failure: (MNURLInspectorFailureBlock)failureBlock;

- (BOOL)validateURL : (NSString *)data;

@end


#endif
