//
//  StartTokenRequest.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StartAPIClientRequest.h"

NS_ASSUME_NONNULL_BEGIN

@class StartCard;

@interface StartTokenRequest : NSObject <StartAPIClientRequest>

- (instancetype)initWithCard:(StartCard *)card NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
