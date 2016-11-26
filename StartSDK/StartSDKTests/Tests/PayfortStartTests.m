//
//  PayfortStartTests.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PayfortStart.h"
#import "PayfortCard.h"
#import "PayfortToken.h"
#import "NSDate+Payfort.h"

@interface PayfortStartTests : XCTestCase

@end

@implementation PayfortStartTests

#pragma mark - Interface methods

- (void)testTokenCreation {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Waiting for token"];

    PayfortCard *card = [[PayfortCard alloc] initWithCardholder:@"Abdullah Mohammed"
                                                         number:@"4242424242424242"
                                                            cvc:@"123"
                                                expirationMonth:[NSDate date].payfortMonth
                                                 expirationYear:[NSDate date].payfortYear];

    PayfortStart *start = [[PayfortStart alloc] initWithAPIKey:@"test_open_k_46dd87e36d3a5949aa68"];

    [start createTokenForCard:card successBlock:^(id <PayfortToken> token) {
        XCTAssertNotNil(token.tokenId);
        [expectation fulfill];
    } errorBlock:^(NSError *error) {
    } cancelBlock:^{
    }];

    [self waitForExpectationsWithTimeout:5.0f handler:nil];
}

@end
