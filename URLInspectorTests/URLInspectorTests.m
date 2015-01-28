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
#import "MasterViewController.h"
#import "RequestEvent.h"
#import "AppDelegate.h"

@interface URLInspectorTests : XCTestCase {
    NSArray *urlContentOKArr, *urlInvalidArr, *urlRedirectArr;
}
@property (nonatomic, readwrite, weak) AppDelegate *appDelegate;
@property (nonatomic, readwrite, weak) MasterViewController *masterController;
@property (nonatomic, readwrite, weak) MNURLRequestManager *mgr;

@property (nonatomic, readwrite, weak) UILabel      *urlLabel;
@property (nonatomic, readwrite, weak) UILabel      *countLabel;
@property (nonatomic, readwrite, weak) UIButton      *goButton;

@end


@implementation URLInspectorTests


- (void)setUp {
    [super setUp];
    urlContentOKArr =  @[ @"http://www.google.com", @"http://www.yahoo.com", @"https://www.chargepoint.com", @"http://still.s3.amazonaws.com/Material/Chimney/images/1.jpg"];
    urlInvalidArr =  @[ @"http://www.goofyurlforthistest.com", @"http://www.forevernow.net/aj3/", @"ftp://asdlfjsdf.com"];
    urlRedirectArr =  @[  @"http://emi.forevernow.net"];

    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.masterController = (MasterViewController *) ((UINavigationController *) self.appDelegate.window.rootViewController).topViewController;

    self.mgr = self.masterController.manager;

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
        XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Good URLs!"];

        MNURLInspectorResultBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Completed url request for %@", [operation.request URL]);
            NSInteger statusCode = [operation.response statusCode];

            XCTAssertEqual(statusCode, 200, @"status code returned resulted in good content!: HTTP %ld", (long)statusCode);
            XCTAssertNotNil(responseObject, @"Successfully retrieved %@", operation.request.URL);

            [expectation fulfill];
        };

        MNURLInspectorFailureBlock failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to make request: %@", [error localizedDescription]);
        };

        [self.mgr getURL: url parameters: nil success:successBlock failure:failureBlock ];

        [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {

            if(error)
            {
                XCTFail(@"Expectation Failed with error: %@", [error localizedDescription]);
            }
            
        }];

    }
}

// expect that the supplied URLs will end up with an error
- (void)testMalformedURLSWithURLManager {

    for (NSString *invalidUrl in urlInvalidArr) {
        XCTestExpectation *expectation = [self expectationWithDescription:@"Testing bad URLs!  These urls are either unsupported or point to an invalid resource."];

        MNURLInspectorResultBlock success =^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Call to %@ resulted in a valid page!", invalidUrl);
            XCTFail(@"%@ resulted in a valid page.  Not expected result", invalidUrl);
        };

        MNURLInspectorFailureBlock failure = ^(AFHTTPRequestOperation *operation, NSError *error) {

//            XCTAssertNotNil(error, @"request should not have returned a result: %@", [error localizedDescription]);
            NSLog(@"Error: %@", [error localizedDescription]);
            [expectation fulfill];
        };

        BOOL requestResult = [self.mgr getURL:invalidUrl parameters:nil
                                      success: success
                                      failure: failure];
        if (!requestResult) {
            NSLog(@"Malformed or unsupoorted URL:  %@", invalidUrl);
            [expectation fulfill];
        } else {
            [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"Error: %@", error);
                    XCTAssertTrue(error != nil, @"request ended in an error as expected: %@", error);
                }
            }];
            

        }
    }

}


- (void)testRedirectURLsWithURLManager {
    for (NSString *url in urlRedirectArr ) {

        XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Redirect URL Works!"];

        MNURLInspectorResultBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Completed url request for %@", [operation.request URL]);
            NSInteger statusCode = [operation.response statusCode];

            XCTAssertLessThan(statusCode, 400, @"status code returned was not a redirect code!: %ld", (long)statusCode);
            XCTAssertGreaterThanOrEqual(statusCode, 300, @"status code returned was not a redirect code!: %ld", (long)statusCode);

            [expectation fulfill];
        };

        MNURLInspectorFailureBlock failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to make request: %@", [error localizedDescription]);
        };

        MNURLInspectorRedirectBlock redirectBlock = ^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {


            [expectation fulfill];
            return request;
        };

        [self.mgr getURL: url parameters: nil success:successBlock failure:failureBlock redirect: redirectBlock];

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
