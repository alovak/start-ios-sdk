//
//  StartVerificationViewController.h
//  StartSDK
//
//  Created by drif on 11/27/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class StartTokenEntity;

typedef void (^StartVerificationViewControllerCancelBlock)();

@interface StartVerificationViewController : UINavigationController

- (instancetype)initWithToken:(StartTokenEntity *)token
                         base:(NSString *)base
                  cancelBlock:(StartVerificationViewControllerCancelBlock)cancelBlock NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
