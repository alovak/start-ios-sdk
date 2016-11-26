//
//  PayfortTokenRequest.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayfortAPIClientRequest.h"

NS_ASSUME_NONNULL_BEGIN

@class PayfortCard;

@interface PayfortTokenRequest : NSObject <PayfortAPIClientRequest>

- (instancetype)initWithCard:(PayfortCard *)card NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
