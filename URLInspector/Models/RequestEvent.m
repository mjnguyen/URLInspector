//
//  RequestEvent.m
//  URLInspector
//
//  Created by Michael Nguyen on 1/27/15.
//
//

#import "RequestEvent.h"


@implementation RequestEvent

@dynamic endTime;
@dynamic responseString;
@dynamic responseSize;
@dynamic startTime;
@dynamic statusCode;
@dynamic url;
@dynamic requestId;


-(NSNumber *)elapsedTime {
    NSTimeInterval diff = [self.endTime timeIntervalSinceDate:self.startTime];
    return [NSNumber numberWithDouble:diff];
}
@end
