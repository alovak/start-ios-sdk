//
//  StartCard.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

#import "StartCard.h"
#import "NSString+Start.h"
#import "NSDate+Start.h"
#import "StartException.h"
#import "StartCardBrandDetector.h"

NSErrorDomain const StartCardError = @"StartCardError";

@interface StartCard ()

@end

@implementation StartCard

#pragma mark - Private methods

- (void)validate {
    NSMutableSet *errors = [NSMutableSet set];

    if (!self.isCardholderValid) {
        [errors addObject:[NSError errorWithDomain:StartCardError code:StartCardErrorCodeInvalidCardholder userInfo:nil]];
    }
    if (!self.isNumberValid) {
        [errors addObject:[NSError errorWithDomain:StartCardError code:StartCardErrorCodeInvalidNumber userInfo:nil]];
    }
    if (!self.isCVCValid) {
        [errors addObject:[NSError errorWithDomain:StartCardError code:StartCardErrorCodeInvalidCVC userInfo:nil]];
    }
    if (!self.isExpirationMonthValid) {
        [errors addObject:[NSError errorWithDomain:StartCardError code:StartCardErrorCodeInvalidExpirationMonth userInfo:nil]];
    }
    if (!self.isExpirationYearValid) {
        [errors addObject:[NSError errorWithDomain:StartCardError code:StartCardErrorCodeInvalidExpirationYear userInfo:nil]];
    }

    if (errors.count) {
        [[StartException exceptionWithName:StartExceptionCardFieldsInvalid reason:nil userInfo:@{
                StartExceptionKeyErrors: errors
        }] raise];
    }
}

- (BOOL)isCardholderValid {
    return _cardholder.length > 0;
}

- (BOOL)isNumberValid {
    return _number.length >= 12 && _number.length <= 19 && self.isSatisfyingLuhn;
}

- (BOOL)isCVCValid {
    return _cvc.length >= 3 && _cvc.length <= 4;
}

- (BOOL)isExpirationMonthValid {
    NSInteger lowBound = (_expirationYear == [NSDate date].startYear) ? [NSDate date].startMonth : 1;
    return _expirationMonth >= lowBound && _expirationMonth <= 12;
}

- (BOOL)isExpirationYearValid {
    return _expirationYear >= [NSDate date].startYear && _expirationYear <= 2100;
}

- (BOOL)isSatisfyingLuhn {
    NSInteger sum = 0;
    for (NSUInteger i = 0; i < _number.length; i++) {
        NSInteger digit = [[_number substringWithRange:NSMakeRange(_number.length - i - 1, 1)] integerValue];
        if (i % 2 == 1) {
            digit *= 2;
        }
        sum += (digit > 9) ? (digit - 9) : digit;
    }
    return sum % 10 == 0;
}

- (void)detectBrand {
    static NSDictionary *brands;
    static dispatch_once_t token;

    dispatch_once(&token, ^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@(StartCardBrandVisa)] = [[StartCardBrandDetector alloc] initWithPrefixes:@[@"4"] lengths:@[@13, @16]];
        dict[@(StartCardBrandMasterCard)] = [[StartCardBrandDetector alloc] initWithPrefixes:@[
                @"23", @"24", @"25", @"26",
                @"50", @"51", @"52", @"53", @"54", @"55",
                @"223", @"224", @"225", @"226", @"227", @"228", @"229",
                @"2221", @"2222", @"2223", @"2224", @"2225", @"2226", @"2227", @"2228", @"2229",
                @"271", @"2720"
        ] lengths:@[@16]];
        brands = dict;
    });

    for (NSNumber *brand in brands) {
        if ([brands[brand] isContainingCard:self]) {
            _brand = (StartCardBrand) brand.integerValue;
            break;
        }
    }
}

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithCardholder:@"" number:@"" cvc:@"" expirationMonth:0 expirationYear:0];
}

#pragma mark - Interface methods

- (instancetype)initWithCardholder:(NSString *)cardholder
                            number:(NSString *)number
                               cvc:(NSString *)cvc
                   expirationMonth:(NSInteger)expirationMonth
                    expirationYear:(NSInteger)expirationYear {

    self = [super init];
    if (self) {
        _cardholder = [cardholder stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        _number = [number startStringByRemovingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet];
        _cvc = [cvc startStringByRemovingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet];
        _expirationMonth = expirationMonth;
        _expirationYear = expirationYear;

        [self validate];
        [self detectBrand];
    }
    return self;
}

- (NSString *)lastDigits {
    return [_number substringFromIndex:_number.length - 4];
}

- (NSString *)bin {
    return [_number substringToIndex:6];
}

@end
