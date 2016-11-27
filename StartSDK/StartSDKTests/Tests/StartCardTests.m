//
//  StartCardTests.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "StartCard.h"
#import "StartException.h"
#import "NSDate+Start.h"

@interface StartCardTests : XCTestCase

@end

@implementation StartCardTests

#pragma mark - Interface methods

- (StartCard *)cardWithNumber:(NSString *)number {
    return [[StartCard alloc] initWithCardholder:@"John Smith"
                                            number:number
                                               cvc:@"123"
                                   expirationMonth:1
                                    expirationYear:2020];
}

- (void)performTestWithCardCreator:(StartCard *(^)(id value))cardCreator
                       validValues:(NSArray *)validValues
                     invalidValues:(NSArray *)invalidValues
                       fieldToTest:(NSString *)fieldToTest
                     errorToExpect:(StartCardErrorCode)errorToExpect {

    @try {
        for (NSString *value in validValues) {
            cardCreator(value);
        }
    }
    @catch (StartException *) {
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
    @catch (StartException *exception) {
        NSMutableSet *exceptionCodes = [NSMutableSet set];
        [exception.userInfo[StartExceptionKeyErrors] enumerateObjectsUsingBlock:^(NSError *error, NSUInteger idx, BOOL *stop) {
            if (error.domain == StartCardError) {
                [exceptionCodes addObject:@(error.code)];
            }
        }];
        return [exceptionCodes isEqualToSet:codes];
    }
    return NO;
}

- (BOOL)gotValidationErrorWithCode:(StartCardErrorCode)code whenExecuting:(void (^)())block {
    return [self gotValidationErrorsWithCodes:[NSSet setWithObject:@(code)] whenExecuting:block];
}

#pragma mark - Interface methods

- (void)testCardholderValidation {
    [self performTestWithCardCreator:^StartCard *(id value) {
        return [[StartCard alloc] initWithCardholder:value
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
    ] fieldToTest:@"cardholder" errorToExpect:StartCardErrorCodeInvalidCardholder];
}

- (void)testNumberValidation {
    [self performTestWithCardCreator:^StartCard *(id value) {
        return [[StartCard alloc] initWithCardholder:@"John Smith"
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
    ] fieldToTest:@"number" errorToExpect:StartCardErrorCodeInvalidNumber];
}

- (void)testCVCValidation {
    [self performTestWithCardCreator:^StartCard *(id value) {
        return [[StartCard alloc] initWithCardholder:@"John Smith"
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
    ] fieldToTest:@"cvc" errorToExpect:StartCardErrorCodeInvalidCVC];
}

- (void)testExpirationMonthValidation {
    [self performTestWithCardCreator:^StartCard *(id value) {
        return [[StartCard alloc] initWithCardholder:@"John Smith"
                                                number:@"4111111111111111"
                                                   cvc:@"123"
                                       expirationMonth:[[value firstObject] integerValue]
                                        expirationYear:[[value lastObject] integerValue] ?: 2020];
    } validValues:@[
            @[@([NSDate date].startMonth), @([NSDate date].startYear)],
            @[@([NSDate date].startMonth + 1), @([NSDate date].startYear)],
            @[@(1), @([NSDate date].startYear + 1)],
            @[@(12), @([NSDate date].startYear + 1)]
    ] invalidValues:@[
            @[@([NSDate date].startMonth - 1), @([NSDate date].startYear)],
            @[@(0), @([NSDate date].startYear + 1)],
            @[@(13), @([NSDate date].startYear + 1)]
    ] fieldToTest:@"expiration month" errorToExpect:StartCardErrorCodeInvalidExpirationMonth];
}

- (void)testExpirationYearValidation {
    [self performTestWithCardCreator:^StartCard *(id value) {
        return [[StartCard alloc] initWithCardholder:@"John Smith"
                                                number:@"4111111111111111"
                                                   cvc:@"123"
                                       expirationMonth:[[value firstObject] integerValue] ?: 1
                                        expirationYear:[[value lastObject] integerValue]];
    } validValues:@[
            @[@([NSDate date].startMonth), @([NSDate date].startYear)],
            @[@([NSDate date].startMonth), @([NSDate date].startYear + 1)]
    ] invalidValues:@[
            @[@([NSDate date].startMonth), @([NSDate date].startYear - 1)]
    ] fieldToTest:@"expiration year" errorToExpect:StartCardErrorCodeInvalidExpirationYear];
}

- (void)testMultipleValidationErrors {
    NSSet *codes = [NSSet setWithObjects:@(StartCardErrorCodeInvalidCVC), @(StartCardErrorCodeInvalidExpirationMonth), nil];
    XCTAssert([self gotValidationErrorsWithCodes:codes whenExecuting:^{
        __unused StartCard *card = [[StartCard alloc] initWithCardholder:@"John Smith"
                                                                  number:@"4111111111111111"
                                                                     cvc:@"123456"
                                                         expirationMonth:13
                                                          expirationYear:2020];
    }], @"Expecting multiple validation exceptions during initialization");

    codes = [NSSet setWithObjects:@(StartCardErrorCodeInvalidCardholder), @(StartCardErrorCodeInvalidNumber), @(StartCardErrorCodeInvalidCVC), nil];
    XCTAssert([self gotValidationErrorsWithCodes:codes whenExecuting:^{
        __unused StartCard *card = [[StartCard alloc] initWithCardholder:@"  "
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
        XCTAssertEqual([self cardWithNumber:number].brand, StartCardBrandVisa, @"Expecting correct Visa detecting");
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
        XCTAssertEqual([self cardWithNumber:number].brand, StartCardBrandMasterCard, @"Expecting correct MasterCard detecting");
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
        XCTAssertEqual([self cardWithNumber:number].brand, StartCardBrandUnknown, @"Expecting correct unknown brands detecting");
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
