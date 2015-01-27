//
//  UrlResponseInfo.m
//  URLInspector
//
//  Created by Michael Nguyen on 1/27/15.
//
//

#import "UrlResponseInfo.h"

@implementation UrlResponseInfo

- (id)initWithHttpOperation: (AFHTTPRequestOperation *)responseOperation requestId: (NSString *)requestIdentifier {
    self = [super init];
    if (self != nil) {
        NSHTTPURLResponse *response = [responseOperation response];
        self.responseString = [responseOperation responseString];
        self.timestamp = [NSDate date];
        NSInteger status = [response statusCode];
        self.statusCode = [NSNumber numberWithInteger: status];
        self.contentLength = [NSNumber numberWithLongLong: [response expectedContentLength]];
        self.requestId = requestIdentifier;
    }

    return self;

}

@end
