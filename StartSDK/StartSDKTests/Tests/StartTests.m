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

@interface StartTests : XCTestCase

@end

@implementation StartTests

#pragma mark - Interface methods

- (void)testTokenCreation {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for token"];

    StartCard *card = [[StartCard alloc] initWithCardholder:@"Abdullah Mohammed"
                                                         number:@"4242424242424242"
                                                            cvc:@"123"
                                                expirationMonth:[NSDate date].startMonth
                                                 expirationYear:[NSDate date].startYear];

    Start *start = [[Start alloc] initWithAPIKey:@"test_open_k_46dd87e36d3a5949aa68"];

    [start createTokenForCard:card successBlock:^(id <StartToken> token) {
        XCTAssertNotNil(token.tokenId);
        [expectation fulfill];
    } errorBlock:^(NSError *error) {
    } cancelBlock:^{
    }];

    [self waitForExpectationsWithTimeout:5.0f handler:nil];
}

@end
