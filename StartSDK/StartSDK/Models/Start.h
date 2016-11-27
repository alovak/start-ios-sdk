//
//  Start.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol StartToken;
@class StartCard;

typedef void (^StartSuccessBlock)(id <StartToken> token);
typedef void (^StartErrorBlock)(NSError *error);
typedef void (^StartCancelBlock)();

extern NSErrorDomain const StartInternalError;

@interface Start : NSObject

- (instancetype)initWithAPIKey:(NSString *)apiKey NS_DESIGNATED_INITIALIZER;

- (void)createTokenForCard:(StartCard *)card
              successBlock:(StartSuccessBlock)successBlock
                errorBlock:(StartErrorBlock)errorBlock
               cancelBlock:(StartCancelBlock)cancelBlock;

@end

NS_ASSUME_NONNULL_END
