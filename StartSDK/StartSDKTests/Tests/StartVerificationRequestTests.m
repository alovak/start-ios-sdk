//
//  StartVerificationRequestTests.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "StartTokenEntity.h"
#import "StartVerificationRequest.h"
#import "StartVerification.h"

@interface StartVerificationRequestTests : XCTestCase

@end

@implementation StartVerificationRequestTests

#pragma mark - Interface methods

- (void)testParams {
    StartTokenEntity *token = [[StartTokenEntity alloc] initWithDictionary:@{
            @"id": @"token_id",
            @"verification_required": @YES
    }];

    StartVerificationRequest *request = [[StartVerificationRequest alloc] initWithToken:token amount:1337 currency:@"BYN" method:@"POST"];

    XCTAssertEqualObjects(request.params[@"amount"], @1337, @"Expecting correct params");
    XCTAssertEqualObjects(request.params[@"currency"], @"BYN", @"Expecting correct params");
    XCTAssertEqualObjects(request.path, @"tokens/token_id/verification", @"Expecting correct path");
    XCTAssertEqualObjects(request.method, @"POST", @"Expecting correct method");
    
    request = [[StartVerificationRequest alloc] initWithToken:token amount:1337 currency:@"BYN" method:@"GET"];
    
    XCTAssertNil(request.params, @"Expecting correct params");
    XCTAssertEqualObjects(request.method, @"GET", @"Expecting correct method");
    for (NSUInteger i = 0; i < 100; i++) {
        [request registerPerforming];
        XCTAssertTrue(request.shouldRetry, @"Expecting unlimited retry");
    }
}

- (void)testResponse {
    StartTokenEntity *token = [[StartTokenEntity alloc] initWithDictionary:@{
            @"id": @"token_id",
            @"verification_required": @YES
    }];

    StartVerificationRequest *request = [[StartVerificationRequest alloc] initWithToken:token amount:1337 currency:@"BYN" method:@"GET"];

    NSArray *invalidResponses = @[
            @{},
            @{@"enrolled": @"id", @"finalized": @"id"},
            @{@"enrolled": @"123", @"finalized": @"234"},
            @{@"enrolled": @YES, @"finalized": @"234"}
    ];
    for (NSDictionary *response in invalidResponses) {
        XCTAssertFalse([request processResponse:response], @"Expecting error while processing");
        XCTAssertNil(request.response, @"Expecting empty response");
    }

    NSDictionary *validResponse = @{
            @"enrolled": @NO,
            @"finalized": @YES
    };

    XCTAssertTrue([request processResponse:validResponse], @"Expecting successful processing");
    XCTAssertFalse([request.response isEnrolled], @"Expecting correct parsing");
    XCTAssertTrue([request.response isFinalized], @"Expecting correct parsing");
    XCTAssertFalse(request.shouldRetry, @"Expecting stopping retry");
}

@end
