//
//  StartAPIClient.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, StartAPIClientErrorCode) {
    StartAPIClientErrorCodeCantFormJSON,
    StartAPIClientErrorCodeInvalidResponse,
    StartAPIClientErrorCodeServerError
};

extern NSErrorDomain const StartAPIClientError;
extern NSInteger const StartAPIClientRetryAttemptsCount;
extern NSTimeInterval const StartAPIClientRetryAttemptsInterval;

@protocol StartAPIClientRequest;

typedef void (^StartAPIClientSuccessBlock)();
typedef void (^StartAPIClientErrorBlock)(NSError *error);

@interface StartAPIClient : NSObject

@property (nonatomic, copy, readonly) NSString *base;

- (instancetype)initWithBase:(NSString *)base apiKey:(NSString *)apiKey NS_DESIGNATED_INITIALIZER;

- (void)performRequest:(id <StartAPIClientRequest>)request
          successBlock:(StartAPIClientSuccessBlock)successBlock
            errorBlock:(StartAPIClientErrorBlock)errorBlock;

@end

NS_ASSUME_NONNULL_END
