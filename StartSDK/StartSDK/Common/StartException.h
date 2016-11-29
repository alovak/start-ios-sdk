//
//  StartException.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/** Name of exception thrown when trying to create StartCard with invalid values. */
extern NSExceptionName const StartExceptionCardFieldsInvalid;

/** Internal exception name. */
extern NSExceptionName const StartExceptionTokenDataInvalid;

/** Internal exception name. */
extern NSExceptionName const StartExceptionVerificationDataInvalid;

/** Exception userInfo key of NSSet of errors caused the exception. */
extern NSString *const StartExceptionKeyErrors;

/** Exception thrown by StartSDK methods. */
@interface StartException : NSException

@end

NS_ASSUME_NONNULL_END
