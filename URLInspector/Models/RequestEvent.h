//
//  RequestEvent.h
//  URLInspector
//
//  Created by Michael Nguyen on 1/27/15.
//  Core Data Entity definition
//  - customized to include elapsedTime, which calculates the time between the start of the request and when it eventually finished.
// 
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RequestEvent : NSManagedObject

@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSString * responseString;
@property (nonatomic, retain) NSNumber * responseSize;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSNumber * statusCode;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * requestId;



- (NSNumber *)elapsedTime;

@end
