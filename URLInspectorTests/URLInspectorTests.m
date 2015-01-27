//
//  URLInspectorTests.m
//  URLInspectorTests
//
//  Created by Michael Nguyen on 1/25/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MNURLRequestManager.h"

@interface URLInspectorTests : XCTestCase {
    MNURLRequestManager *mgr;
    NSArray *urlContentOKArr, *urlInvalidArr, *urlRedirectArr;
}

@end

@implementation URLInspectorTests

- (void)setUp {
    [super setUp];
    urlContentOKArr =  @[ @"http://www.google.com", @"http://www.yahoo.com", @"https://www.chargepoint.com", @"http://still.s3.amazonaws.com/Material/Chimney/images/1.jpg"];
    urlInvalidArr =  @[ @"http://www.goofyurlforthistest.com", @"http://www.forevernow.net/aj3/"];
    urlRedirectArr =  @[  @"http://emi.forevernow.net"];

    // Put setup code here. This method is called before the invocation of each test method in the class.

    mgr = [MNURLRequestManager sharedInstance];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testOnePlusOne {
    // This is an example of a functional test case.
    XCTAssertEqual( 1 + 1, 2, @"One plus one should always equal two.  If this test fails, something is really wrong.");
}


// Test a connection out to Google.com
- (void)testGoodURLsWithURLManager {

    for (NSString *url in urlContentOKArr ) {
        NSLog(@"Testing %@", url);
        XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Good URLs!"];

        MNURLInspectorResultBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Completed url request for %@", [operation.request URL]);
            NSInteger statusCode = [operation.response statusCode];

            XCTAssertEqual(statusCode, 200);
            XCTAssertNotNil(responseObject, @"Successfully retrieved %@", operation.request.URL);
            [expectation fulfill];
        };

        MNURLInspectorFailureBlock failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to make request: %@", [error localizedDescription]);
        };


        [mgr getURL: url parameters: nil success:successBlock failure:failureBlock];

        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {

            if(error)
            {
                XCTFail(@"Expectation Failed with error: %@", [error localizedDescription]);
            }
            
        }];

    }
}

- (void)testMalformedURLSWithURLManager {
    for (NSString *invalidUrl in urlInvalidArr) {
        XCTAssertFalse([self->mgr getURL:invalidUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            XCTFail(@"Call to %@ resulted in a valid page!", invalidUrl);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            XCTFail(@"Call to %@ resulted in a valid page!", invalidUrl);
        } followRedirect:YES]);
    }

}

- (void)testRedirectURLsWithURLManager {
    for (NSString *url in urlRedirectArr ) {

        XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Redirect URL Works!"];

        MNURLInspectorResultBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Completed url request for %@", [operation.request URL]);
            NSInteger statusCode = [operation.response statusCode];

            XCTAssertLessThan(statusCode, 400, @"status code returned was not a redirect code!: %d", statusCode);
            XCTAssertGreaterThanOrEqual(statusCode, 300, @"status code returned was not a redirect code!: %d", statusCode);

            [expectation fulfill];
        };

        MNURLInspectorFailureBlock failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to make request: %@", [error localizedDescription]);
        };

        [mgr getURL: url parameters: nil success:successBlock failure:failureBlock followRedirect: NO];

        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {

            if(error)
            {
                XCTFail(@"Expectation Failed with error: %@", [error localizedDescription]);
            }
            
        }];
        
    }
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
