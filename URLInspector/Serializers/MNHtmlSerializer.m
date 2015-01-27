//
//  MNHtmlSerializer.m
//  URLInspector
//
//  Created by Michael Nguyen on 1/26/15.
//
//

#import "MNHtmlSerializer.h"
#import "AFURLResponseSerialization.h"

@implementation MNHtmlSerializer

+ (instancetype)serializer {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/plain", nil];

    return self;
}

- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error) {
            return nil;
        }
    }

    return data;
}

@end
