//
//  UrlResponseInfo.h
//  URLInspector
//
//  Created by Michael Nguyen on 1/27/15.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface UrlResponseInfo : NSObject

@property (nonatomic, strong) NSNumber *statusCode;
@property (nonatomic, strong) NSString *responseString;
@property (nonatomic, strong) NSDate   *timestamp;
@property (nonatomic, strong) NSString *requestURI;
@property (nonatomic, strong) NSNumber *contentLength;
@property (nonatomic, strong) NSString *requestId;

- (id)initWithHttpOperation: (AFHTTPRequestOperation *)responseOperation requestId: (NSString *)requestIdentifier;
@end
