//
//  StartCard.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/** Card brand detected by StartCard. */
typedef NS_ENUM(NSInteger, StartCardBrand) {
    StartCardBrandUnknown,
    StartCardBrandVisa,
    StartCardBrandMasterCard
};

/** Code of error with StartCardError domain. */
typedef NS_ENUM(NSInteger, StartCardErrorCode) {
    StartCardErrorCodeInvalidCardholder,
    StartCardErrorCodeInvalidNumber,
    StartCardErrorCodeInvalidCVC,
    StartCardErrorCodeInvalidExpirationYear,
    StartCardErrorCodeInvalidExpirationMonth
};

/** Domain of error occured when executing StartCard methods. */
extern NSErrorDomain const StartCardError;

/** Represents a card for charges. */
@interface StartCard : NSObject

/** Name of the holder of the card with whitespace chars trimmed. F.e. "John Smith". */
@property (nonatomic, copy, readonly) NSString *cardholder;

/** Card number with non-digit chars removed. F.e. "4242424242424242". */
@property (nonatomic, copy, readonly) NSString *number;

/** Card CVC code with non-digit chars removed. F.e. "123". */
@property (nonatomic, copy, readonly) NSString *cvc;

/** Card expiration month. "1" stays for January, "12" -- for December. */
@property (nonatomic, assign, readonly) NSInteger expirationMonth;

/** Card expiration year in full 4-digit form. F.e. "2020". */
@property (nonatomic, assign, readonly) NSInteger expirationYear;

/** Brand (f.e. Visa, MasterCard) of the card detected using the card number. */
@property (nonatomic, assign, readonly) StartCardBrand brand;

/** Last 4 digits of the card number. */
@property (nonatomic, copy, readonly) NSString *lastDigits;

/** First 6 digits of the card number. */
@property (nonatomic, copy, readonly) NSString *bin;

/** Creates StartCard object representing the card specified.
 *
 * @throws StartException with StartExceptionCardFieldsInvalid name containing errors with StartCardError domain and StartCardErrorCode codes for StartExceptionKeyErrors key in userInfo.
 *
 * @param cardholder Name of the holder of the card; whitespace chars will be trimmed; valid value example: "John Smith"
 * @param number Card number; non-digit chars will be ignored; valid values examples: "4242424242424242", "4242-4242-4242-4242", "4242 4242 4242 4242".
 * @param cvc CVC card code; non-digit chars will be ignored; valid values examples: "123", "1-123".
 * @param expirationMonth Card expiration month; "1" stays for January, "12" -- for December.
 * @param expirationYear Card expiration year in full 4-digit form, f.e. "2020".
 *
 * @returns StartCard object represeting the card specified.
 */
- (instancetype)initWithCardholder:(NSString *)cardholder
                            number:(NSString *)number
                               cvc:(NSString *)cvc
                   expirationMonth:(NSInteger)expirationMonth
                    expirationYear:(NSInteger)expirationYear NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
