//
//  PayfortCardTests.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PayfortCard.h"
#import "PayfortException.h"
#import "NSDate+Payfort.h"

@interface PayfortCardTests : XCTestCase

@end

@implementation PayfortCardTests

#pragma mark - Interface methods

- (PayfortCard *)cardWithNumber:(NSString *)number {
    return [[PayfortCard alloc] initWithCardholder:@"John Smith"
                                            number:number
                                               cvc:@"123"
                                   expirationMonth:1
                                    expirationYear:2020];
}

- (void)performTestWithCardCreator:(PayfortCard *(^)(id value))cardCreator
                       validValues:(NSArray *)validValues
                     invalidValues:(NSArray *)invalidValues
                       fieldToTest:(NSString *)fieldToTest
                     errorToExpect:(PayfortCardErrorCode)errorToExpect {

    @try {
        for (NSString *value in validValues) {
            cardCreator(value);
        }
    }
    @catch (PayfortException *) {
        XCTAssert(NO, @"Expecting successful initialization with correct %@ value", fieldToTest);
    }

    for (NSString *value in invalidValues) {
        XCTAssert([self gotValidationErrorWithCode:errorToExpect whenExecuting:^{
            cardCreator(value);
        }], @"Expecting validation exception during initialization with invalid %@ value", fieldToTest);
    }
    XCTAssert([self gotValidationErrorWithCode:errorToExpect whenExecuting:^{
        cardCreator(nil);
    }], @"Expecting validation exception during initialization with invalid %@ value", fieldToTest);
}

- (BOOL)gotValidationErrorsWithCodes:(NSSet *)codes whenExecuting:(void (^)())block {
    @try {
        block();
    }
    @catch (PayfortException *exception) {
        NSMutableSet *exceptionCodes = [NSMutableSet set];
        [exception.userInfo[PayfortExceptionKeyErrors] enumerateObjectsUsingBlock:^(NSError *error, NSUInteger idx, BOOL *stop) {
            if (error.domain == PayfortCardError) {
                [exceptionCodes addObject:@(error.code)];
            }
        }];
        return [exceptionCodes isEqualToSet:codes];
    }
    return NO;
}

- (BOOL)gotValidationErrorWithCode:(PayfortCardErrorCode)code whenExecuting:(void (^)())block {
    return [self gotValidationErrorsWithCodes:[NSSet setWithObject:@(code)] whenExecuting:block];
}

#pragma mark - Interface methods

- (void)testCardholderValidation {
    [self performTestWithCardCreator:^PayfortCard *(id value) {
        return [[PayfortCard alloc] initWithCardholder:value
                                                number:@"4111111111111111"
                                                   cvc:@"123"
                                       expirationMonth:1
                                        expirationYear:2020];
    } validValues:@[
            @"John Smith",
            @"  \tJohn Smith   ",
            @"J"
    ] invalidValues:@[
            @"",
            @"   \t  \n  "
    ] fieldToTest:@"cardholder" errorToExpect:PayfortCardErrorCodeInvalidCardholder];
}

- (void)testNumberValidation {
    [self performTestWithCardCreator:^PayfortCard *(id value) {
        return [[PayfortCard alloc] initWithCardholder:@"John Smith"
                                                number:value
                                                   cvc:@"123"
                                       expirationMonth:1
                                        expirationYear:2020];
    } validValues:@[
            @"378 2822 4631 0005",
            @"3714-4963-5398-43-1",
            @"3787\\t3449\\t367 10-00",
            @"5610591081018250",
            @"30569309025904",
            @"38520000023237",
            @"6011111111111117",
            @"6011000990139424",
            @"3530111333300000",
            @"3566002020360505",
            @"5555555555554444",
            @"5105105105105100",
            @"4111111111111111",
            @"4012888888881881",
            @"4222222222222",
            @"5019717010103742",
            @"6331101999990016"
    ] invalidValues:@[
            @"4111111111111112",
            @"1",
            @"a",
            @"aa111111111111111"
    ] fieldToTest:@"number" errorToExpect:PayfortCardErrorCodeInvalidNumber];
}

- (void)testCVCValidation {
    [self performTestWithCardCreator:^PayfortCard *(id value) {
        return [[PayfortCard alloc] initWithCardholder:@"John Smith"
                                                number:@"4111111111111111"
                                                   cvc:value
                                       expirationMonth:1
                                        expirationYear:2020];
    } validValues:@[
            @"123",
            @"1234",
            @"  123   "
    ] invalidValues:@[
            @"",
            @"12",
            @"12345",
            @"abc"
    ] fieldToTest:@"cvc" errorToExpect:PayfortCardErrorCodeInvalidCVC];
}

- (void)testExpirationMonthValidation {
    [self performTestWithCardCreator:^PayfortCard *(id value) {
        return [[PayfortCard alloc] initWithCardholder:@"John Smith"
                                                number:@"4111111111111111"
                                                   cvc:@"123"
                                       expirationMonth:[[value firstObject] integerValue]
                                        expirationYear:[[value lastObject] integerValue] ?: 2020];
    } validValues:@[
            @[@([NSDate date].payfortMonth), @([NSDate date].payfortYear)],
            @[@([NSDate date].payfortMonth + 1), @([NSDate date].payfortYear)],
            @[@(1), @([NSDate date].payfortYear + 1)],
            @[@(12), @([NSDate date].payfortYear + 1)]
    ] invalidValues:@[
            @[@([NSDate date].payfortMonth - 1), @([NSDate date].payfortYear)],
            @[@(0), @([NSDate date].payfortYear + 1)],
            @[@(13), @([NSDate date].payfortYear + 1)]
    ] fieldToTest:@"expiration month" errorToExpect:PayfortCardErrorCodeInvalidExpirationMonth];
}

- (void)testExpirationYearValidation {
    [self performTestWithCardCreator:^PayfortCard *(id value) {
        return [[PayfortCard alloc] initWithCardholder:@"John Smith"
                                                number:@"4111111111111111"
                                                   cvc:@"123"
                                       expirationMonth:[[value firstObject] integerValue] ?: 1
                                        expirationYear:[[value lastObject] integerValue]];
    } validValues:@[
            @[@([NSDate date].payfortMonth), @([NSDate date].payfortYear)],
            @[@([NSDate date].payfortMonth), @([NSDate date].payfortYear + 1)]
    ] invalidValues:@[
            @[@([NSDate date].payfortMonth), @([NSDate date].payfortYear - 1)]
    ] fieldToTest:@"expiration year" errorToExpect:PayfortCardErrorCodeInvalidExpirationYear];
}

- (void)testMultipleValidationErrors {
    NSSet *codes = [NSSet setWithObjects:@(PayfortCardErrorCodeInvalidCVC), @(PayfortCardErrorCodeInvalidExpirationMonth), nil];
    XCTAssert([self gotValidationErrorsWithCodes:codes whenExecuting:^{
        [[PayfortCard alloc] initWithCardholder:@"John Smith"
                                         number:@"4111111111111111"
                                            cvc:@"123456"
                                expirationMonth:13
                                 expirationYear:2020];
    }], @"Expecting multiple validation exceptions during initialization");

    codes = [NSSet setWithObjects:@(PayfortCardErrorCodeInvalidCardholder), @(PayfortCardErrorCodeInvalidNumber), @(PayfortCardErrorCodeInvalidCVC), nil];
    XCTAssert([self gotValidationErrorsWithCodes:codes whenExecuting:^{
        [[PayfortCard alloc] initWithCardholder:@"  "
                                         number:@"1234111111111111111"
                                            cvc:@"123456"
                                expirationMonth:1
                                 expirationYear:2020];
    }], @"Expecting multiple validation exceptions during initialization");
}

- (void)testBrandDetecting {
    NSArray *visaNumbers = @[
            @"4000056655665556",
            @"4242424242424242",
            @"4012 8888 8888 1881",
            @"4111 1111 1111 1111",
            @"4222 2222 2222 2",
            @"4917 6100 0000 0000"
    ];

    for (NSString *number in visaNumbers) {
        XCTAssertEqual([self cardWithNumber:number].brand, PayfortCardBrandVisa, @"Expecting correct Visa detecting");
    }

    NSArray *masterCardNumbers = @[
            @"5200828282828210",
            @"5274 5763 9425 9961",
            @"5555 5555 5555 4444",
            @"5105 1051 0510 5100",
            @"2720 1700 0000 0006",
            @"2223 4800 0000 0001",
            @"2223 0400 0000 0003",
            @"2223 0700 0000 0000",
            @"2223 2700 0000 0006",
            @"2720 3500 0000 0004",
            @"2223 1000 0000 0005",
            @"2720 0500 0000 0000"
    ];

    for (NSString *number in masterCardNumbers) {
        XCTAssertEqual([self cardWithNumber:number].brand, PayfortCardBrandMasterCard, @"Expecting correct MasterCard detecting");
    }

    NSArray *unknownNumbers = @[
            @"371449635398431",
            @"378282246310005",
            @"6011000990139424",
            @"30569309025904",
            @"38520000023237",
            @"3530111333300000",
            @"3566002020360505",
            @"0000000000000000"
    ];

    for (NSString *number in unknownNumbers) {
        XCTAssertEqual([self cardWithNumber:number].brand, PayfortCardBrandUnknown, @"Expecting correct unknown brands detecting");
    }
}

- (void)testLastDigits {
    XCTAssertEqualObjects([self cardWithNumber:@"371449635398431"].lastDigits, @"8431", @"Expecting valid last digits");
    XCTAssertEqualObjects([self cardWithNumber:@"30569309025904"].lastDigits, @"5904", @"Expecting valid last digits");
    XCTAssertEqualObjects([self cardWithNumber:@"0000000000000000"].lastDigits, @"0000", @"Expecting valid last digits");
}

- (void)testBin {
    XCTAssertEqualObjects([self cardWithNumber:@"3714-4963-5398431"].bin, @"371449", @"Expecting valid bin");
    XCTAssertEqualObjects([self cardWithNumber:@" 3056 9309 0259 04"].bin, @"305693", @"Expecting valid bin");
    XCTAssertEqualObjects([self cardWithNumber:@"0000000000000000"].bin, @"000000", @"Expecting valid bin");
}

@end
