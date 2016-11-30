//
//  StartTests.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Start.h"
#import "StartCard.h"
#import "StartToken.h"
#import "NSDate+Start.h"
#import "StartOperation.h"
#import "StartAPIClient.h"
#import "StartVerificationViewController.h"
#import "StartTokenEntity.h"

typedef void (^StartTestsBlock)();

@interface StartVerificationViewController (StartTests)

- (void)onCancel:(UIButton *)button;

@end

@interface StartTestsVerificationViewController : StartVerificationViewController

@end

@implementation StartTestsVerificationViewController

#pragma mark - StartVerificationViewController methods

- (instancetype)initWithToken:(StartTokenEntity *)token
                         base:(NSString *)base
                  cancelBlock:(StartVerificationViewControllerCancelBlock)cancelBlock {
    self = [super initWithToken:token base:base cancelBlock:cancelBlock];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self onCancel:nil];
    });
    return self;
}

@end

@interface StartOperation (StartTests)

- (void)showVerificationAlert;
- (void)finalizeVerification;

@end

@interface StartTestsStartOperation : StartOperation

@property (nonatomic, copy) StartTestsBlock onFinalize;

@end

@implementation StartTestsStartOperation

#pragma mark - StartOperation methods

- (void)showVerificationAlert {
    if (self.onFinalize) {
        self.onFinalize();
    }
    else {
        [self finalizeVerification];
    }
}

- (StartVerificationViewController *)verificationViewControllerWithCancelBlock:(StartVerificationViewControllerCancelBlock)cancelBlock {
    StartTokenEntity *token = [[StartTokenEntity alloc] initWithDictionary:@{@"id": @"id", @"verification_required": @YES}];
    return [[StartTestsVerificationViewController alloc] initWithToken:token
                                                                  base:@""
                                                           cancelBlock:cancelBlock];
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
    return [StartCard cardWithCardholder:@"Abdullah Mohammed"
                                          number:number
                                             cvc:@"123"
                                 expirationMonth:[NSDate date].startMonth
                                  expirationYear:[NSDate date].startYear
                                           error:nil];
}

#pragma mark - Interface methods

- (void)testValidation {
    Start *start = [Start startWithAPIKey:@"test_open_k_46dd87e36d3a5949aa68"];

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
    XCTestExpectation *authErrorExpectation = [self expectationWithDescription:@"Waiting for auth error"];

    Start *start = [Start startWithAPIKey:@"test_open_k_46dd87e36d3a5949aa68 api key"];

    [start createTokenForCard:self.card amount:1 currency:@"USD" successBlock:^(id <StartToken> token) {
    } errorBlock:^(NSError *error) {
        XCTAssertTrue([error.userInfo[StartErrorKeyResponse] hasPrefix:@"{\"error\":"], @"Expecting response in error");
        XCTAssertEqual(error.domain, StartError, @"Expecting valid error domain");
        XCTAssertEqual(error.code, StartErrorCodeInvalidAPIKey, @"Expecting valid error code");
        XCTAssertTrue(NSThread.isMainThread, @"Expecting completion block on main thread");
        [authErrorExpectation fulfill];
    } cancelBlock:^{
    }];

    XCTestExpectation *internalErrorExpectation = [self expectationWithDescription:@"Waiting for internal error"];

    StartAPIClient *client = [[StartAPIClient alloc] initWithBase:@"https://google.com/" apiKey:@"example"];
    StartOperation *operation = [[StartOperation alloc] initWithAPIClient:client
                                                                     card:self.card
                                                                   amount:1
                                                                 currency:@"USD"
                                                             successBlock:^(id <StartToken> token) {}
                                                               errorBlock:^(NSError *error) {
                                                                   XCTAssertEqual(error.code, StartErrorCodeInternalError, @"Expecting valid error code");
                                                                   [internalErrorExpectation fulfill];
                                                               }
                                                              cancelBlock:^{}];
    [operation perform];

    [self waitForExpectationsWithTimeout:15.0f handler:nil];
}

- (void)testTokenWithVerificationNotRequired {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for token"];

    Start *start = [Start startWithAPIKey:@"test_open_k_46dd87e36d3a5949aa68"];

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

    Start *start = [Start startWithAPIKey:@"live_open_k_55e06cde7fe8d3141a7e"];

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

    StartAPIClient *client = [[StartAPIClient alloc] initWithBase:@"https://api.start.payfort.com/" apiKey:@"live_open_k_55e06cde7fe8d3141a7e"];
    StartTestsStartOperation *operation = [[StartTestsStartOperation alloc] initWithAPIClient:client
                                                                                         card:[self cardWithNumber:@"5453010000064154"]
                                                                                       amount:1
                                                                                     currency:@"USD"
                                                                                 successBlock:^(id <StartToken> token) {}
                                                                                   errorBlock:^(NSError *error) {}
                                                                                  cancelBlock:^{}];
    operation.onFinalize = ^{
        [expectation fulfill];
    };
    [operation perform];

    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)testTokenWithVerificationRequiredEnrolledAndCancelled {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for cancel"];

    StartAPIClient *client = [[StartAPIClient alloc] initWithBase:@"https://api.start.payfort.com/" apiKey:@"live_open_k_55e06cde7fe8d3141a7e"];
    StartTestsStartOperation *operation = [[StartTestsStartOperation alloc] initWithAPIClient:client
                                                                                         card:[self cardWithNumber:@"5453010000064154"]
                                                                                       amount:1
                                                                                     currency:@"USD"
                                                                                 successBlock:^(id <StartToken> token) {}
                                                                                   errorBlock:^(NSError *error) {}
                                                                                  cancelBlock:^{
                                                                                      XCTAssertTrue(NSThread.isMainThread, @"Expecting completion block on main thread");
                                                                                      [expectation fulfill];
                                                                                  }];
    [operation perform];

    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

@end
