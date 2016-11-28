//
//  StartCard.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, StartCardBrand) {
    StartCardBrandUnknown,
    StartCardBrandVisa,
    StartCardBrandMasterCard
};

typedef NS_ENUM(NSInteger, StartCardErrorCode) {
    StartCardErrorCodeInvalidCardholder,
    StartCardErrorCodeInvalidNumber,
    StartCardErrorCodeInvalidCVC,
    StartCardErrorCodeInvalidExpirationYear,
    StartCardErrorCodeInvalidExpirationMonth
};

extern NSErrorDomain const StartCardError;

@interface StartCard : NSObject

@property (nonatomic, copy, readonly) NSString *cardholder;
@property (nonatomic, copy, readonly) NSString *number;
@property (nonatomic, copy, readonly) NSString *cvc;
@property (nonatomic, assign, readonly) NSInteger expirationMonth;
@property (nonatomic, assign, readonly) NSInteger expirationYear;

@property (nonatomic, assign, readonly) StartCardBrand brand;
@property (nonatomic, copy, readonly) NSString *lastDigits;
@property (nonatomic, copy, readonly) NSString *bin;

- (instancetype)initWithCardholder:(NSString *)cardholder
                            number:(NSString *)number
                               cvc:(NSString *)cvc
                   expirationMonth:(NSInteger)expirationMonth
                    expirationYear:(NSInteger)expirationYear NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
