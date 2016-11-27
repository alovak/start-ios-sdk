//
//  StartTests.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Start.h"
#import "StartCard.h"
#import "StartToken.h"
#import "NSDate+Start.h"
#import "StartTokenEntity.h"

typedef void (^StartTestsBlock)();

@interface StartTestsStart : Start

@property (nonatomic, copy) StartTestsBlock onFinalize;

@end

@implementation StartTestsStart

#pragma mark - Start methods

- (void)finalizeVerificationForToken:(StartTokenEntity *)token
                              amount:(NSInteger)amount
                            currency:(NSString *)currency
                        successBlock:(StartSuccessBlock)successBlock
                          errorBlock:(StartErrorBlock)errorBlock
                         cancelBlock:(StartCancelBlock)cancelBlock {
    self.onFinalize();
}

@end

@interface StartTests : XCTestCase

@end

@implementation StartTests

#pragma mark - Private methods

- (StartCard *)card {
    return [self cardWithNumber:@"4242424242424242"];
}

- (StartCard *)cardWithNumber:(NSString *)number {
    return [[StartCard alloc] initWithCardholder:@"Abdullah Mohammed"
                                          number:number
                                             cvc:@"123"
                                 expirationMonth:[NSDate date].startMonth
                                  expirationYear:[NSDate date].startYear];
}

#pragma mark - Interface methods

- (void)testValidation {
    Start *start = [[Start alloc] initWithAPIKey:@"test_open_k_46dd87e36d3a5949aa68"];

    XCTestExpectation *zeroAmountErrorExpectation = [self expectationWithDescription:@"Waiting for amount error"];

    [start createTokenForCard:self.card amount:0 currency:@"USD" successBlock:^(id <StartToken> token) {
    } errorBlock:^(NSError *error) {
        XCTAssertEqual(error.domain, StartError, @"Expecting valid error domain");
        XCTAssertEqual(error.code, StartErrorCodeInvalidAmount, @"Expecting valid error code");
        [zeroAmountErrorExpectation fulfill];
    } cancelBlock:^{
    }];

    XCTestExpectation *negativeAmountErrorExpectation = [self expectationWithDescription:@"Waiting for amount error"];

    [start createTokenForCard:self.card amount:-1 currency:@"USD" successBlock:^(id <StartToken> token) {
    } errorBlock:^(NSError *error) {
        XCTAssertEqual(error.domain, StartError, @"Expecting valid error domain");
        XCTAssertEqual(error.code, StartErrorCodeInvalidAmount, @"Expecting valid error code");
        [negativeAmountErrorExpectation fulfill];
    } cancelBlock:^{
    }];

    XCTestExpectation *currencyErrorExpectation = [self expectationWithDescription:@"Waiting for currency error"];

    [start createTokenForCard:self.card amount:1 currency:@"USDU" successBlock:^(id <StartToken> token) {
    } errorBlock:^(NSError *error) {
        XCTAssertEqual(error.domain, StartError, @"Expecting valid error domain");
        XCTAssertEqual(error.code, StartErrorCodeInvalidCurrency, @"Expecting valid error code");
        [currencyErrorExpectation fulfill];
    } cancelBlock:^{
    }];

    [self waitForExpectationsWithTimeout:1.0f handler:nil];
}

- (void)testError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for error"];

    Start *start = [[Start alloc] initWithAPIKey:@"invalid api key"];

    [start createTokenForCard:self.card amount:1 currency:@"USD" successBlock:^(id <StartToken> token) {
    } errorBlock:^(NSError *error) {
        XCTAssertEqual(error.domain, StartError, @"Expecting valid error domain");
        XCTAssertEqual(error.code, StartErrorCodeInternalError, @"Expecting valid error code");
        XCTAssertTrue(NSThread.isMainThread, @"Expecting completion block on main thread");
        [expectation fulfill];
    } cancelBlock:^{
    }];

    [self waitForExpectationsWithTimeout:15.0f handler:nil];
}

- (void)testTokenWithVerificationNotRequired {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for token"];

    Start *start = [[Start alloc] initWithAPIKey:@"test_open_k_46dd87e36d3a5949aa68"];

    [start createTokenForCard:self.card amount:1 currency:@"USD" successBlock:^(id <StartToken> token) {
        XCTAssertNotNil(token.tokenId, @"Expecting token in completion block");
        XCTAssertTrue(NSThread.isMainThread, @"Expecting completion block on main thread");
        [expectation fulfill];
    } errorBlock:^(NSError *error) {
    } cancelBlock:^{
    }];

    [self waitForExpectationsWithTimeout:5.0f handler:nil];
}

- (void)testTokenWithVerificationRequiredNotEnrolled {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for token"];

    Start *start = [[Start alloc] initWithAPIKey:@"live_open_k_55e06cde7fe8d3141a7e"];

    [start createTokenForCard:self.card amount:1 currency:@"USD" successBlock:^(id <StartToken> token) {
        XCTAssertNotNil(token.tokenId, @"Expecting token in completion block");
        [expectation fulfill];
    } errorBlock:^(NSError *error) {
    } cancelBlock:^{
    }];

    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)testTokenWithVerificationRequiredEnrolled {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for finalization"];

    StartTestsStart *start = [[StartTestsStart alloc] initWithAPIKey:@"live_open_k_55e06cde7fe8d3141a7e"];
    start.onFinalize = ^{
        [expectation fulfill];
    };

    [start createTokenForCard:[self cardWithNumber:@"5453010000064154"] amount:1 currency:@"USD" successBlock:^(id <StartToken> token) {
    } errorBlock:^(NSError *error) {
    } cancelBlock:^{
    }];

    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

@end
