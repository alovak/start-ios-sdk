//
//  StartTokenEntity.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

#import "StartToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface StartTokenEntity : NSObject <StartToken>

@property (nonatomic, copy, readonly) NSString *tokenId;
@property (nonatomic, assign, readonly) BOOL isVerificationRequired;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
