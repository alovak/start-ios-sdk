//
//  PayfortException.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSExceptionName const PayfortExceptionCardFieldsInvalid;
extern NSExceptionName const PayfortExceptionTokenDataInvalid;

extern NSString *const PayfortExceptionKeyErrors;

@interface PayfortException : NSException

@end

NS_ASSUME_NONNULL_END
