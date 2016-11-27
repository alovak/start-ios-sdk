//
//  StartException.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSExceptionName const StartExceptionCardFieldsInvalid;
extern NSExceptionName const StartExceptionTokenDataInvalid;

extern NSString *const StartExceptionKeyErrors;

@interface StartException : NSException

@end

NS_ASSUME_NONNULL_END
