//
//  Start.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

@import UIKit;

#import "Start.h"
#import "StartToken.h"
#import "StartAPIClient.h"
#import "StartTokenRequest.h"
#import "StartCard.h"
#import "StartTokenEntity.h"
#import "StartVerificationRequest.h"
#import "StartVerification.h"
#import "UIViewController+Start.h"
#import "StartVerificationViewController.h"

static NSString *const StartBase = @"https://api.start.payfort.com/";

NSErrorDomain const StartError = @"StartError";

@implementation Start {
    StartAPIClient *_apiClient;
}

#pragma mark - Private methods

- (void)createVerificationForToken:(StartTokenEntity *)token
                            amount:(NSInteger)amount
                          currency:(NSString *)currency
                      successBlock:(StartSuccessBlock)successBlock
                        errorBlock:(StartErrorBlock)errorBlock
                       cancelBlock:(StartCancelBlock)cancelBlock {

    StartVerificationRequest *verificationRequest = [[StartVerificationRequest alloc] initWithToken:token
                                                                                             amount:amount
                                                                                           currency:currency
                                                                                             method:@"POST"];

    [_apiClient performRequest:verificationRequest successBlock:^(id <StartAPIClientRequest> request) {
        if ([request.response isEnrolled]) {
            [self finalizeVerificationForToken:token
                                        amount:amount
                                      currency:currency
                                  successBlock:successBlock
                                    errorBlock:errorBlock
                                   cancelBlock:cancelBlock];
        }
        else {
            successBlock(token);
        }
    } errorBlock:^(id <StartAPIClientRequest> request, NSError *error) {
        [self handleError:error errorBlock:errorBlock];
    }];
}

- (void)finalizeVerificationForToken:(StartTokenEntity *)token
                            amount:(NSInteger)amount
                          currency:(NSString *)currency
                      successBlock:(StartSuccessBlock)successBlock
                        errorBlock:(StartErrorBlock)errorBlock
                       cancelBlock:(StartCancelBlock)cancelBlock {

    StartVerificationRequest *verificationRequest = [[StartVerificationRequest alloc] initWithToken:token
                                                                                             amount:amount
                                                                                           currency:currency
                                                                                             method:@"GET"];

    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController.topPresentedViewController;
    StartVerificationViewController *verificationViewController = [[StartVerificationViewController alloc] initWithToken:token
                                                                                                                    base:StartBase
                                                                                                             cancelBlock:^{
        [rootViewController dismissViewControllerAnimated:YES completion:nil];
        [verificationRequest cancel];
        cancelBlock();
    }];
    [rootViewController presentViewController:verificationViewController animated:YES completion:nil];

    [_apiClient performRequest:verificationRequest successBlock:^(id <StartAPIClientRequest> request) {
        [rootViewController dismissViewControllerAnimated:YES completion:nil];
        successBlock(token);
    } errorBlock:^(id <StartAPIClientRequest> request, NSError *error) {
        [self handleError:error errorBlock:errorBlock];
    }];
}

- (void)handleError:(NSError *)error errorBlock:(StartErrorBlock)errorBlock {
    if (error.domain == StartAPIClientError) {
        error = [NSError errorWithDomain:StartError code:StartErrorCodeInternalError userInfo:nil];
    }
    errorBlock(error);
}

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithAPIKey:@""];
}

#pragma mark - Interface methods

- (instancetype)initWithAPIKey:(NSString *)apiKey {
    self = [super init];
    if (self) {
        _apiClient = [[StartAPIClient alloc] initWithBase:StartBase apiKey:apiKey];
    }
    return self;
}

- (void)createTokenForCard:(StartCard *)card
                    amount:(NSInteger)amount
                  currency:(NSString *)currency
              successBlock:(StartSuccessBlock)successBlock
                errorBlock:(StartErrorBlock)errorBlock
               cancelBlock:(StartCancelBlock)cancelBlock {

    if (amount <= 0) {
        errorBlock([NSError errorWithDomain:StartError code:StartErrorCodeInvalidAmount userInfo:nil]);
        return;
    }

    if (currency.length != 3) {
        errorBlock([NSError errorWithDomain:StartError code:StartErrorCodeInvalidCurrency userInfo:nil]);
        return;
    }

    [_apiClient performRequest:[[StartTokenRequest alloc] initWithCard:card] successBlock:^(id <StartAPIClientRequest> request) {
        StartTokenEntity *token = request.response;
        if (token.isVerificationRequired) {
            [self createVerificationForToken:token
                                      amount:amount
                                    currency:currency
                                successBlock:successBlock
                                  errorBlock:errorBlock
                                 cancelBlock:cancelBlock];
        }
        else {
            successBlock(token);
        }
    } errorBlock:^(id <StartAPIClientRequest> request, NSError *error) {
        [self handleError:error errorBlock:errorBlock];
    }];
}

@end
