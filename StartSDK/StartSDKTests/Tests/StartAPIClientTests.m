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

typedef void (^StartAPIClientTestsClientBlock)(NSURLRequest *request);

@interface StartAPIClient (Test)

- (void)handleRequest:(id <StartAPIClientRequest>)request
             response:(NSURLResponse *)response
                 data:(NSData *)data
                error:(NSError *)error
         successBlock:(StartAPIClientSuccessBlock)successBlock
           errorBlock:(StartAPIClientErrorBlock)errorBlock;

@end

@interface StartAPIClientTestsResponse : NSHTTPURLResponse

@property (nonatomic, assign) NSInteger code;

@end

@implementation StartAPIClientTestsResponse

#pragma mark - NSHTTPURLResponse methods

- (NSInteger)statusCode {
    return self.code;
}

@end

@interface StartAPIClientTestsClient : StartAPIClient

@property (nonatomic, copy) StartAPIClientTestsClientBlock onPerformURLRequest;
@property (nonatomic, strong) StartAPIClientTestsResponse *response;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSError *error;

@end

@implementation StartAPIClientTestsClient

#pragma mark - PayfortAPIClient methods

- (void)performURLRequest:(NSURLRequest *)urlRequest
                  request:(id <StartAPIClientRequest>)request
             successBlock:(StartAPIClientSuccessBlock)successBlock
               errorBlock:(StartAPIClientErrorBlock)errorBlock {
    if (self.onPerformURLRequest) {
        self.onPerformURLRequest(urlRequest);
    }
    else {
        [self handleRequest:request response:self.response data:self.data error:self.error successBlock:successBlock errorBlock:errorBlock];
    }
}

@end

@interface StartAPIClientTestsRequest : NSObject <StartAPIClientRequest>

@property (nonatomic, strong) NSDictionary *response;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, assign) BOOL isForcedToFailProcess;

@end

@implementation StartAPIClientTestsRequest

#pragma mark - PayfortAPIClientRequest protocol

- (NSString *)method {
    return @"POST";
}

- (NSString *)path {
    return @"path";
}

- (NSDictionary *)params {
    return self.data;
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

- (void)expect:(StartAPIClientErrorCode)errorCode whilePerforming:(StartAPIClientTestsRequest *)clientRequest on:(StartAPIClientTestsClient *)client with:(XCTestExpectation *)expectation {
    [client performRequest:clientRequest successBlock:^(id <StartAPIClientRequest> request) {
    } errorBlock:^(id <StartAPIClientRequest> request, NSError *error) {
        XCTAssertEqual(error.domain, StartAPIClientError, @"Expecting valid error domain");
        XCTAssertEqual(error.code, errorCode, @"Expecting valid error code");
        [expectation fulfill];
    }];
}

#pragma mark - Interface methods

- (void)testRequestForming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for forming request"];

    StartAPIClientTestsClient *client = [[StartAPIClientTestsClient alloc] initWithBase:@"http://example.com/" apiKey:@"example"];
    client.onPerformURLRequest = ^(NSURLRequest *request) {

        XCTAssertEqualObjects(request.allHTTPHeaderFields[@"Authorization"], @"Basic ZXhhbXBsZQ==", @"Expecting valid authorization header");
        XCTAssertEqualObjects(request.URL.absoluteString, @"http://example.com/path", @"Expecting valid URL");
        XCTAssertEqualObjects([[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding], @"{\"key\":\"value\"}", @"Expecting valid body");

        [expectation fulfill];
    };

    StartAPIClientTestsRequest *clientRequest = [[StartAPIClientTestsRequest alloc] init];
    clientRequest.data = @{
            @"key": @"value"
    };

    [client performRequest:clientRequest successBlock:^(id <StartAPIClientRequest> request) {
    } errorBlock:^(id <StartAPIClientRequest> request, NSError *error) {
    }];

    [self waitForExpectationsWithTimeout:1.0f handler:nil];
}

- (void)testResponse {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for response"];

    StartAPIClientTestsClient *client = [[StartAPIClientTestsClient alloc] initWithBase:@"http://example.com/" apiKey:@"example"];
    client.data = [@"{\"key\":\"value\"}" dataUsingEncoding:NSUTF8StringEncoding];
    client.response = [[StartAPIClientTestsResponse alloc] init];
    client.response.code = 200;

    StartAPIClientTestsRequest *clientRequest = [[StartAPIClientTestsRequest alloc] init];
    clientRequest.data = @{
            @"key": @"value"
    };

    [client performRequest:clientRequest successBlock:^(id <StartAPIClientRequest> request) {
        XCTAssertNotNil(request.response, @"Expecting response to present");
        [expectation fulfill];
    } errorBlock:^(id <StartAPIClientRequest> request, NSError *error) {
        NSLog(@"%@", error);
    }];

    [self waitForExpectationsWithTimeout:1.0f handler:nil];
}

- (void)testErrors {
    StartAPIClientTestsClient *client = [[StartAPIClientTestsClient alloc] initWithBase:@"http://example.com/" apiKey:@"example"];
    client.response = [[StartAPIClientTestsResponse alloc] init];
    client.data = [@"{\"key\":\"value\"}" dataUsingEncoding:NSUTF8StringEncoding];

    StartAPIClientTestsRequest *clientRequest = [[StartAPIClientTestsRequest alloc] init];
    clientRequest.data = @{
            @"key": @"value"
    };

    XCTestExpectation *serverErrorExpectation = [self expectationWithDescription:@"Waiting for server error"];
    client.response.code = 400;
    [self expect:StartAPIClientErrorCodeServerError whilePerforming:clientRequest on:client with:serverErrorExpectation];

    XCTestExpectation *cantProcessErrorExpectation = [self expectationWithDescription:@"Waiting for can't process error"];
    client.response.code = 200;
    clientRequest.isForcedToFailProcess = YES;
    [self expect:StartAPIClientErrorCodeInvalidResponse whilePerforming:clientRequest on:client with:cantProcessErrorExpectation];

    XCTestExpectation *invalidResponseExpectation = [self expectationWithDescription:@"Waiting for invalid response error"];
    clientRequest.isForcedToFailProcess = NO;
    client.data = [NSData data];
    [self expect:StartAPIClientErrorCodeInvalidResponse whilePerforming:clientRequest on:client with:invalidResponseExpectation];

    XCTestExpectation *invalidRequestExpectation = [self expectationWithDescription:@"Waiting for invalid request error"];
    clientRequest.data = nil;
    [self expect:StartAPIClientErrorCodeCantFormJSON whilePerforming:clientRequest on:client with:invalidRequestExpectation];

    XCTestExpectation *customErrorExpectation = [self expectationWithDescription:@"Waiting for custom error"];
    client.error = [NSError errorWithDomain:@"Test" code:0 userInfo:nil];
    clientRequest.data = @{
            @"key": @"value"
    };

    [client performRequest:clientRequest successBlock:^(id <StartAPIClientRequest> request) {
    } errorBlock:^(id <StartAPIClientRequest> request, NSError *error) {
        XCTAssertEqual(error, client.error, @"Expecting valid error");
        [customErrorExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1.0f handler:nil];
}

@end
