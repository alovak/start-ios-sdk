//
//  StartToken.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol StartToken <NSObject>

@property (nonatomic, copy, readonly) NSString *tokenId;

@end

NS_ASSUME_NONNULL_END
