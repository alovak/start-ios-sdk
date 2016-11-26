//
//  PayfortCard.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PayfortCardErrorCode) {
    PayfortCardErrorCodeInvalidCardholder,
    PayfortCardErrorCodeInvalidNumber,
    PayfortCardErrorCodeInvalidCVC,
    PayfortCardErrorCodeInvalidExpirationYear,
    PayfortCardErrorCodeInvalidExpirationMonth
};

typedef NS_ENUM(NSInteger, PayfortCardBrand) {
    PayfortCardBrandUnknown,
    PayfortCardBrandVisa,
    PayfortCardBrandMasterCard
};

extern NSErrorDomain const PayfortCardError;

@interface PayfortCard : NSObject

@property (nonatomic, copy, readonly) NSString *cardholder;
@property (nonatomic, copy, readonly) NSString *number;
@property (nonatomic, copy, readonly) NSString *cvc;
@property (nonatomic, assign, readonly) NSInteger expirationMonth;
@property (nonatomic, assign, readonly) NSInteger expirationYear;

@property (nonatomic, assign, readonly) PayfortCardBrand brand;
@property (nonatomic, copy, readonly) NSString *lastDigits;
@property (nonatomic, copy, readonly) NSString *bin;

- (instancetype)initWithCardholder:(NSString *)cardholder
                            number:(NSString *)number
                               cvc:(NSString *)cvc
                   expirationMonth:(NSInteger)expirationMonth
                    expirationYear:(NSInteger)expirationYear NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
