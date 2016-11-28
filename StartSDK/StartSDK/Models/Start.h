//
//  Start.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

#define StartLocalizationKeyVerificationMessage @"payfort_start_verification_message"
#define StartLocalizationKeyVerificationButton @"payfort_start_verification_button"

@protocol StartToken;
@class StartCard;

typedef void (^StartSuccessBlock)(id <StartToken> token);
typedef void (^StartErrorBlock)(NSError *error);
typedef void (^StartCancelBlock)();

typedef NS_ENUM(NSInteger, StartErrorCode) {
    StartErrorCodeInternalError,
    StartErrorCodeInvalidAPIKey,
    StartErrorCodeInvalidAmount,
    StartErrorCodeInvalidCurrency
};

extern NSErrorDomain const StartError;
extern NSString *const StartErrorKeyResponse;

@interface Start : NSObject

- (instancetype)initWithAPIKey:(NSString *)apiKey NS_DESIGNATED_INITIALIZER;

- (void)createTokenForCard:(StartCard *)card
                    amount:(NSInteger)amount
                  currency:(NSString *)currency
              successBlock:(StartSuccessBlock)successBlock
                errorBlock:(StartErrorBlock)errorBlock
               cancelBlock:(StartCancelBlock)cancelBlock;

@end

NS_ASSUME_NONNULL_END
