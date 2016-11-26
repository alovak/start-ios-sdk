//
//  PayfortStart.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PayfortToken;
@class PayfortCard;

typedef void (^PayfortStartSuccessBlock)(id <PayfortToken> token);
typedef void (^PayfortStartErrorBlock)(NSError *error);
typedef void (^PayfortStartCancelBlock)();

extern NSErrorDomain const PayfortStartInternalError;

@interface PayfortStart : NSObject

- (instancetype)initWithAPIKey:(NSString *)apiKey NS_DESIGNATED_INITIALIZER;

- (void)createTokenForCard:(PayfortCard *)card
              successBlock:(PayfortStartSuccessBlock)successBlock
                errorBlock:(PayfortStartErrorBlock)errorBlock
               cancelBlock:(PayfortStartCancelBlock)cancelBlock;

@end

NS_ASSUME_NONNULL_END
