//
//  PayfortAPIClientTests.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PayfortAPIClient.h"
#import "PayfortAPIClientRequest.h"

typedef void (^CustomPayfortAPIClientBlock)(NSURLRequest *request);

@interface PayfortAPIClient (Test)

- (void)handleRequest:(id <PayfortAPIClientRequest>)request
             response:(NSURLResponse *)response
                 data:(NSData *)data
                error:(NSError *)error
         successBlock:(PayfortAPIClientSuccessBlock)successBlock
           errorBlock:(PayfortAPIClientErrorBlock)errorBlock;

@end

@interface PayfortAPIClientTestsResponse : NSHTTPURLResponse

@property (nonatomic, assign) NSInteger code;

@end

@implementation PayfortAPIClientTestsResponse

#pragma mark - NSHTTPURLResponse methods

- (NSInteger)statusCode {
    return self.code;
}

@end

@interface PayfortAPIClientTestsClient : PayfortAPIClient

@property (nonatomic, copy) CustomPayfortAPIClientBlock onPerformURLRequest;
@property (nonatomic, strong) PayfortAPIClientTestsResponse *response;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSError *error;

@end

@implementation PayfortAPIClientTestsClient

#pragma mark - PayfortAPIClient methods

- (void)performURLRequest:(NSURLRequest *)urlRequest
                  request:(id <PayfortAPIClientRequest>)request
             successBlock:(PayfortAPIClientSuccessBlock)successBlock
               errorBlock:(PayfortAPIClientErrorBlock)errorBlock {
    if (self.onPerformURLRequest) {
        self.onPerformURLRequest(urlRequest);
    }
    else {
        [self handleRequest:request response:self.response data:self.data error:self.error successBlock:successBlock errorBlock:errorBlock];
    }
}

@end

@interface PayfortAPIClientTestsRequest : NSObject <PayfortAPIClientRequest>

@property (nonatomic, strong) NSDictionary *response;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, assign) BOOL isForcedToFailProcess;

@end

@implementation PayfortAPIClientTestsRequest

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

@interface PayfortAPIClientTests : XCTestCase

@end

@implementation PayfortAPIClientTests

#pragma mark - Private methods

- (void)expect:(PayfortAPIClientErrorCode)errorCode whilePerforming:(PayfortAPIClientTestsRequest *)clientRequest on:(PayfortAPIClientTestsClient *)client with:(XCTestExpectation *)expectation {
    [client performRequest:clientRequest successBlock:^(id <PayfortAPIClientRequest> request) {
    } errorBlock:^(id <PayfortAPIClientRequest> request, NSError *error) {
        XCTAssertEqual(error.domain, PayfortAPIClientError, @"Expecting valid error domain");
        XCTAssertEqual(error.code, errorCode, @"Expecting valid error code");
        [expectation fulfill];
    }];
}

#pragma mark - Interface methods

- (void)testRequestForming {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for forming request"];

    PayfortAPIClientTestsClient *client = [[PayfortAPIClientTestsClient alloc] initWithBase:@"http://example.com/" apiKey:@"example"];
    client.onPerformURLRequest = ^(NSURLRequest *request) {

        XCTAssertEqualObjects(request.allHTTPHeaderFields[@"Authorization"], @"Basic ZXhhbXBsZQ==", @"Expecting valid authorization header");
        XCTAssertEqualObjects(request.URL.absoluteString, @"http://example.com/path", @"Expecting valid URL");
        XCTAssertEqualObjects([[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding], @"{\"key\":\"value\"}", @"Expecting valid body");

        [expectation fulfill];
    };

    PayfortAPIClientTestsRequest *clientRequest = [[PayfortAPIClientTestsRequest alloc] init];
    clientRequest.data = @{
            @"key": @"value"
    };

    [client performRequest:clientRequest successBlock:^(id <PayfortAPIClientRequest> request) {
    } errorBlock:^(id <PayfortAPIClientRequest> request, NSError *error) {
    }];

    [self waitForExpectationsWithTimeout:1.0f handler:nil];
}

- (void)testResponse {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for response"];

    PayfortAPIClientTestsClient *client = [[PayfortAPIClientTestsClient alloc] initWithBase:@"http://example.com/" apiKey:@"example"];
    client.data = [@"{\"key\":\"value\"}" dataUsingEncoding:NSUTF8StringEncoding];
    client.response = [[PayfortAPIClientTestsResponse alloc] init];
    client.response.code = 200;

    PayfortAPIClientTestsRequest *clientRequest = [[PayfortAPIClientTestsRequest alloc] init];
    clientRequest.data = @{
            @"key": @"value"
    };

    [client performRequest:clientRequest successBlock:^(id <PayfortAPIClientRequest> request) {
        XCTAssertNotNil(request.response, @"Expecting response to present");
        [expectation fulfill];
    } errorBlock:^(id <PayfortAPIClientRequest> request, NSError *error) {
        NSLog(@"%@", error);
    }];

    [self waitForExpectationsWithTimeout:1.0f handler:nil];
}

- (void)testErrors {
    PayfortAPIClientTestsClient *client = [[PayfortAPIClientTestsClient alloc] initWithBase:@"http://example.com/" apiKey:@"example"];
    client.response = [[PayfortAPIClientTestsResponse alloc] init];
    client.data = [@"{\"key\":\"value\"}" dataUsingEncoding:NSUTF8StringEncoding];

    PayfortAPIClientTestsRequest *clientRequest = [[PayfortAPIClientTestsRequest alloc] init];
    clientRequest.data = @{
            @"key": @"value"
    };

    XCTestExpectation *serverErrorExpectation = [self expectationWithDescription:@"Waiting for server error"];
    client.response.code = 400;
    [self expect:PayfortAPIClientErrorCodeServerError whilePerforming:clientRequest on:client with:serverErrorExpectation];

    XCTestExpectation *cantProcessErrorExpectation = [self expectationWithDescription:@"Waiting for can't process error"];
    client.response.code = 200;
    clientRequest.isForcedToFailProcess = YES;
    [self expect:PayfortAPIClientErrorCodeInvalidResponse whilePerforming:clientRequest on:client with:cantProcessErrorExpectation];

    XCTestExpectation *invalidResponseExpectation = [self expectationWithDescription:@"Waiting for invalid response error"];
    clientRequest.isForcedToFailProcess = NO;
    client.data = [NSData data];
    [self expect:PayfortAPIClientErrorCodeInvalidResponse whilePerforming:clientRequest on:client with:invalidResponseExpectation];

    XCTestExpectation *invalidRequestExpectation = [self expectationWithDescription:@"Waiting for invalid request error"];
    clientRequest.data = nil;
    [self expect:PayfortAPIClientErrorCodeCantFormJSON whilePerforming:clientRequest on:client with:invalidRequestExpectation];

    XCTestExpectation *customErrorExpectation = [self expectationWithDescription:@"Waiting for custom error"];
    client.error = [NSError errorWithDomain:@"Test" code:0 userInfo:nil];
    clientRequest.data = @{
            @"key": @"value"
    };

    [client performRequest:clientRequest successBlock:^(id <PayfortAPIClientRequest> request) {
    } errorBlock:^(id <PayfortAPIClientRequest> request, NSError *error) {
        NSLog(@"%@", error);
        XCTAssertEqual(error, client.error, @"Expecting valid error");
        [customErrorExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1.0f handler:nil];
}

@end
