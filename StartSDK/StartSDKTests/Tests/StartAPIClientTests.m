//
//  StartAPIClientTests.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "StartAPIClient.h"
#import "StartAPIClientRequest.h"
#import "StartAPIClientOperation.h"

typedef void (^StartAPIClientTestsBlock)(NSURLRequest *request);

@interface StartAPIClientTestsResponse : NSHTTPURLResponse

@property (nonatomic, assign) NSInteger code;

@end

@implementation StartAPIClientTestsResponse

#pragma mark - NSHTTPURLResponse methods

- (NSInteger)statusCode {
    return self.code;
}

@end

@interface StartAPIClientTestsSession : NSURLSession

@property (nonatomic, copy) StartAPIClientTestsBlock onDataTask;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) StartAPIClientTestsResponse *response;
@property (nonatomic, strong) NSError *error;

@end

@implementation StartAPIClientTestsSession

#pragma mark - NSURLSession methods

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    if (self.onDataTask) {
        self.onDataTask(request);
    }
    completionHandler(self.data, self.response, self.error);
    return nil;
}

@end

@interface StartAPIClientTestsRequest : NSObject <StartAPIClientRequest>

@property (nonatomic, strong) NSDictionary *response;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, assign) NSInteger attemptsExpected;
@property (nonatomic, assign) NSInteger attemptsPerformed;
@property (nonatomic, assign) BOOL isForcedToFailProcess;

@end

@implementation StartAPIClientTestsRequest

#pragma mark - PayfortAPIClientRequest protocol

- (NSString *)method {
    return @"POST";
}

- (NSString *)path {
    return @"tokens";
}

- (NSDictionary *)params {
    return self.data;
}

- (BOOL)shouldRetry {
    return self.attemptsExpected > 0;
}

- (NSTimeInterval)retryInterval {
    return 0.0f;
}

- (void)registerPerforming {
    self.attemptsPerformed++;
    self.attemptsExpected--;
}

- (BOOL)processResponse:(NSDictionary *)response {
    self.response = response;
    return self.isForcedToFailProcess ? NO : (response != nil);
}

@end

@interface StartAPIClientTests : XCTestCase

@end

@implementation StartAPIClientTests

#pragma mark - Private methods

- (void)expectErrorCode:(StartAPIClientErrorCode)errorCode
        whilePerforming:(StartAPIClientTestsRequest *)clientRequest
                     on:(StartAPIClientTestsSession *)session
                   with:(XCTestExpectation *)expectation {
    StartAPIClientOperation *operation = [[StartAPIClientOperation alloc] initWithBase:@"http://example.com/"
                                                                         authorization:@"Basic ZXhhbXBsZQ=="
                                                                               session:session
                                                                               request:clientRequest
                                                                          successBlock:^{}
                                                                            errorBlock:^(NSError *error) {
                                                                                XCTAssertEqual(error.domain, StartAPIClientError, @"Expecting valid error domain");
                                                                                XCTAssertEqual(error.code, errorCode, @"Expecting valid error code");
                                                                                [expectation fulfill];
                                                                            }];
    [operation perform];
}

#pragma mark - Interface methods

- (void)testRequestForming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for forming request"];

    StartAPIClientTestsSession *session = [[StartAPIClientTestsSession alloc] init];
    session.onDataTask = ^(NSURLRequest *request) {

        XCTAssertEqualObjects(request.allHTTPHeaderFields[@"Authorization"], @"Basic ZXhhbXBsZQ==", @"Expecting valid authorization header");
        XCTAssertEqual([request.allHTTPHeaderFields[@"StartiOS"] componentsSeparatedByString:@"."].count, 3, @"Expecting valid info header");
        XCTAssertEqualObjects(request.URL.absoluteString, @"http://example.com/tokens", @"Expecting valid URL");
        XCTAssertEqualObjects([[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding], @"{\"key\":\"value\"}", @"Expecting valid body");

        [expectation fulfill];
    };

    StartAPIClientTestsRequest *clientRequest = [[StartAPIClientTestsRequest alloc] init];
    clientRequest.data = @{
            @"key": @"value"
    };

    StartAPIClientOperation *operation = [[StartAPIClientOperation alloc] initWithBase:@"http://example.com/"
                                                                         authorization:@"Basic ZXhhbXBsZQ=="
                                                                               session:session
                                                                               request:clientRequest
                                                                          successBlock:^{}
                                                                            errorBlock:^(NSError *error) {}];
    [operation perform];

    [self waitForExpectationsWithTimeout:1.0f handler:nil];
}

- (void)testResponse {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for response"];

    StartAPIClientTestsSession *session = [[StartAPIClientTestsSession alloc] init];
    session.data = [@"{\"key\":\"value\"}" dataUsingEncoding:NSUTF8StringEncoding];
    session.response = [[StartAPIClientTestsResponse alloc] init];
    session.response.code = 200;

    StartAPIClientTestsRequest *clientRequest = [[StartAPIClientTestsRequest alloc] init];
    clientRequest.data = @{
            @"key": @"value"
    };

    StartAPIClientOperation *operation = [[StartAPIClientOperation alloc] initWithBase:@"http://example.com/"
                                                                         authorization:@"Basic ZXhhbXBsZQ=="
                                                                               session:session
                                                                               request:clientRequest
                                                                          successBlock:^{
                                                                              XCTAssertNotNil(clientRequest.response, @"Expecting response to present");
                                                                              [expectation fulfill];
                                                                          }
                                                                            errorBlock:^(NSError *error) {}];
    [operation perform];

    [self waitForExpectationsWithTimeout:1.0f handler:nil];
}

- (void)testErrors {
    StartAPIClientTestsSession *session = [[StartAPIClientTestsSession alloc] init];
    session.data = [@"{\"key\":\"value\"}" dataUsingEncoding:NSUTF8StringEncoding];
    session.response = [[StartAPIClientTestsResponse alloc] init];

    StartAPIClientTestsRequest *clientRequest = [[StartAPIClientTestsRequest alloc] init];
    clientRequest.data = @{
            @"key": @"value"
    };

    XCTestExpectation *serverErrorExpectation = [self expectationWithDescription:@"Waiting for server error"];
    session.response.code = 400;
    [self expectErrorCode:StartAPIClientErrorCodeServerError whilePerforming:clientRequest on:session with:serverErrorExpectation];

    XCTestExpectation *cantProcessErrorExpectation = [self expectationWithDescription:@"Waiting for can't process error"];
    session.response.code = 200;
    clientRequest.isForcedToFailProcess = YES;
    [self expectErrorCode:StartAPIClientErrorCodeInvalidResponse whilePerforming:clientRequest on:session with:cantProcessErrorExpectation];

    XCTestExpectation *cantProcessErrorResponseExpectation = [self expectationWithDescription:@"Waiting for can't process error"];
    StartAPIClientOperation *operation = [[StartAPIClientOperation alloc] initWithBase:@"http://example.com/"
                                                                         authorization:@"Basic ZXhhbXBsZQ=="
                                                                               session:session
                                                                               request:clientRequest
                                                                          successBlock:^{}
                                                                            errorBlock:^(NSError *error) {
                                                                                XCTAssertEqualObjects(error.userInfo[StartAPIClientErrorKeyResponse], @"{\"key\":\"value\"}", @"Expecting valid error");
                                                                                [cantProcessErrorResponseExpectation fulfill];
                                                                            }];
    [operation perform];

    XCTestExpectation *invalidResponseExpectation = [self expectationWithDescription:@"Waiting for invalid response error"];
    clientRequest.isForcedToFailProcess = NO;
    session.data = [NSData data];
    [self expectErrorCode:StartAPIClientErrorCodeInvalidResponse whilePerforming:clientRequest on:session with:invalidResponseExpectation];

    XCTestExpectation *invalidRequestExpectation = [self expectationWithDescription:@"Waiting for invalid request error"];
    clientRequest.data = @{@"window": [[UIWindow alloc] init]};
    [self expectErrorCode:StartAPIClientErrorCodeCantFormJSON whilePerforming:clientRequest on:session with:invalidRequestExpectation];

    XCTestExpectation *customErrorExpectation = [self expectationWithDescription:@"Waiting for custom error"];
    session.error = [NSError errorWithDomain:@"Test" code:0 userInfo:nil];
    clientRequest.data = @{
            @"key": @"value"
    };

    operation = [[StartAPIClientOperation alloc] initWithBase:@"http://example.com/"
                                                                         authorization:@"Basic ZXhhbXBsZQ=="
                                                                               session:session
                                                                               request:clientRequest
                                                                          successBlock:^{}
                                                                            errorBlock:^(NSError *error) {
                                                                                XCTAssertEqual(error, session.error, @"Expecting valid error");
                                                                                [customErrorExpectation fulfill];
                                                                            }];
    [operation perform];

    [self waitForExpectationsWithTimeout:1.0f handler:nil];
}

- (void)testRetry {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for error"];

    StartAPIClientTestsRequest *clientRequest = [[StartAPIClientTestsRequest alloc] init];
    clientRequest.attemptsExpected = 3;

    StartAPIClientOperation *operation = [[StartAPIClientOperation alloc] initWithBase:@"http://example.com/"
                                                                         authorization:@"Basic ZXhhbXBsZQ=="
                                                                               session:NSURLSession.sharedSession
                                                                               request:clientRequest
                                                                          successBlock:^{}
                                                                            errorBlock:^(NSError *error) {
                                                                                XCTAssertEqual(clientRequest.attemptsPerformed, 3, @"Expecting valid amount of attempts");
                                                                                [expectation fulfill];
                                                                            }];

    [operation perform];

    [self waitForExpectationsWithTimeout:1.0f handler:nil];
}

- (void)testNoRetry {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for error"];

    StartAPIClientTestsRequest *clientRequest = [[StartAPIClientTestsRequest alloc] init];
    clientRequest.attemptsExpected = 3;

    StartAPIClientOperation *operation = [[StartAPIClientOperation alloc] initWithBase:@"https://api.start.payfort.com/"
                                                                         authorization:@"Basic ZXhhbXBsZQ=="
                                                                               session:NSURLSession.sharedSession
                                                                               request:clientRequest
                                                                          successBlock:^{}
                                                                            errorBlock:^(NSError *error) {
                                                                                XCTAssertEqual(clientRequest.attemptsPerformed, 1, @"Expecting valid amount of attempts");
                                                                                [expectation fulfill];
                                                                            }];

    [operation perform];

    [self waitForExpectationsWithTimeout:1.0f handler:nil];
}

@end
