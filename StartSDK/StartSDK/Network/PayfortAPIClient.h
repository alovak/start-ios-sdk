//
//  PayfortAPIClient.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PayfortAPIClientErrorCode) {
    PayfortAPIClientErrorCodeCantFormJSON,
    PayfortAPIClientErrorCodeInvalidResponse,
    PayfortAPIClientErrorCodeServerError
};

extern NSErrorDomain const PayfortAPIClientError;

@protocol PayfortAPIClientRequest;

typedef void (^PayfortAPIClientSuccessBlock)(id <PayfortAPIClientRequest> request);
typedef void (^PayfortAPIClientErrorBlock)(id <PayfortAPIClientRequest> request, NSError *error);

@interface PayfortAPIClient : NSObject

- (instancetype)initWithBase:(NSString *)base apiKey:(NSString *)apiKey NS_DESIGNATED_INITIALIZER;

- (void)performRequest:(id <PayfortAPIClientRequest>)request
          successBlock:(PayfortAPIClientSuccessBlock)successBlock
            errorBlock:(PayfortAPIClientErrorBlock)errorBlock;

@end

NS_ASSUME_NONNULL_END
