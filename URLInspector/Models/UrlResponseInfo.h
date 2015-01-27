//
//  UrlResponseInfo.h
//  URLInspector
//
//  Created by Michael Nguyen on 1/27/15.
//
//  class to model a response Object.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface UrlResponseInfo : NSObject

@property (nonatomic, strong) NSNumber *statusCode;     // response code
@property (nonatomic, strong) NSString *responseString; // string form of response
@property (nonatomic, strong) NSDate   *timestamp;  // timestamp response ended.
@property (nonatomic, strong) NSString *requestURI; // original URI requested
@property (nonatomic, strong) NSNumber *contentLength;  // content size received
@property (nonatomic, strong) NSString *requestId;

- (id)initWithHttpOperation: (AFHTTPRequestOperation *)responseOperation requestId: (NSString *)requestIdentifier;
@end
