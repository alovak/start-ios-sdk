//
//  PayfortToken.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PayfortToken <NSObject>

@property (nonatomic, copy, readonly) NSString *tokenId;

@end

NS_ASSUME_NONNULL_END
