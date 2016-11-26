//
//  PayfortTokenRequestTests.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PayfortCard.h"
#import "PayfortTokenRequest.h"
#import "PayfortToken.h"
#import "PayfortTokenEntity.h"

@interface PayfortTokenRequestTests : XCTestCase

@end

@implementation PayfortTokenRequestTests

#pragma mark - Interface methods

- (void)testParams {
    PayfortCard *card = [[PayfortCard alloc] initWithCardholder:@"John Smith"
                                                         number:@"4111111111111111"
                                                            cvc:@"123"
                                                expirationMonth:1
                                                 expirationYear:2020];

    PayfortTokenRequest *request = [[PayfortTokenRequest alloc] initWithCard:card];

    XCTAssertEqual(request.params[@"name"], card.cardholder, @"Expecting correct params");
    XCTAssertEqual(request.params[@"number"], card.number, @"Expecting correct params");
    XCTAssertEqual(request.params[@"cvc"], card.cvc, @"Expecting correct params");
    XCTAssertEqual([request.params[@"exp_month"] integerValue], card.expirationMonth, @"Expecting correct params");
    XCTAssertEqual([request.params[@"exp_year"] integerValue], card.expirationYear, @"Expecting correct params");
}

- (void)testResponse {
    PayfortCard *card = [[PayfortCard alloc] initWithCardholder:@"John Smith"
                                                         number:@"4111111111111111"
                                                            cvc:@"123"
                                                expirationMonth:1
                                                 expirationYear:2020];

    PayfortTokenRequest *request = [[PayfortTokenRequest alloc] initWithCard:card];

    NSArray *invalidResponses = @[
            @{},
            @{@"id": @"id", @"verification_required": @"id"}
    ];
    for (NSDictionary *response in invalidResponses) {
        XCTAssertFalse([request processResponse:response], @"Expecting error while processing");
        XCTAssertNil(request.response, @"Expecting empty response");
    }

    NSDictionary *validResponse = @{
            @"id": @"id-value",
            @"verification_required": @YES
    };

    XCTAssertTrue([request processResponse:validResponse], @"Expecting successful processing");
    XCTAssertEqual([request.response tokenId], validResponse[@"id"], @"Expecting correct parsing");
    XCTAssertTrue([request.response isVerificationRequired], @"Expecting correct parsing");
}

@end
