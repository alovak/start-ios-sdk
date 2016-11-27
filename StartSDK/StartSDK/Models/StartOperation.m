//
//  StartOperation.m
//  StartSDK
//
//  Created by drif on 11/27/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import "StartOperation.h"
#import "StartAPIClient.h"
#import "StartCard.h"
#import "StartTokenRequest.h"
#import "StartTokenEntity.h"
#import "StartVerificationRequest.h"
#import "StartVerification.h"
#import "StartVerificationViewController.h"
#import "UIViewController+Start.h"

@implementation StartOperation {
    StartAPIClient *_apiClient;

    StartCard *_card;
    NSInteger _amount;
    NSString *_currency;

    StartSuccessBlock _successBlock;
    StartErrorBlock _errorBlock;
    StartCancelBlock _cancelBlock;

    StartTokenEntity *_token;
}

#pragma mark - Private methods

- (StartVerificationRequest *)verificationRequestWithMethod:(NSString *)method {
    return [[StartVerificationRequest alloc] initWithToken:_token
                                                    amount:_amount
                                                  currency:_currency
                                                    method:method];
}

- (StartVerificationViewController *)verificationViewControllerWithCancelBlock:(StartVerificationViewControllerCancelBlock)cancelBlock {
    return [[StartVerificationViewController alloc] initWithToken:_token
                                                             base:_apiClient.base
                                                      cancelBlock:cancelBlock];
}

- (void)createToken {
    StartTokenRequest *tokenRequest = [[StartTokenRequest alloc] initWithCard:_card];

    [_apiClient performRequest:tokenRequest successBlock:^{
        StartTokenEntity *token = tokenRequest.response;
        if (token.isVerificationRequired) {
            self->_token = token;
            [self createVerification];
        }
        else {
            self->_successBlock(token);
        }
    } errorBlock:^(NSError *error) {
        [self handleError:error];
    }];
}

- (void)createVerification {
    StartVerificationRequest *verificationRequest = [self verificationRequestWithMethod:@"POST"];

    [_apiClient performRequest:verificationRequest successBlock:^{
        if ([verificationRequest.response isEnrolled]) {
            [self finalizeVerification];
        }
        else {
            self->_successBlock(self->_token);
        }
    } errorBlock:^(NSError *error) {
        [self handleError:error];
    }];
}

- (void)finalizeVerification {
    StartVerificationRequest *verificationRequest = [self verificationRequestWithMethod:@"GET"];

    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController.topPresentedViewController;
    StartVerificationViewController *verificationViewController = [self verificationViewControllerWithCancelBlock:^{
        [rootViewController dismissViewControllerAnimated:YES completion:nil];
        [verificationRequest cancel];
        self->_cancelBlock();
    }];
    [rootViewController presentViewController:verificationViewController animated:YES completion:nil];

    [_apiClient performRequest:verificationRequest successBlock:^{
        [rootViewController dismissViewControllerAnimated:YES completion:nil];
        self->_successBlock(self->_token);
    } errorBlock:^(NSError *error) {
        [self handleError:error];
    }];
}

- (void)handleError:(NSError *)error {
    if (error.domain == StartAPIClientError) {
        error = [NSError errorWithDomain:StartError code:StartErrorCodeInternalError userInfo:nil];
    }
    _errorBlock(error);
}

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithAPIClient:[[StartAPIClient alloc] init]
                              card:[[StartCard alloc] init]
                            amount:0
                          currency:@""
                      successBlock:^(id <StartToken> token) {}
                        errorBlock:^(NSError *error) {}
                       cancelBlock:^{}];
}


#pragma mark - Interface methods

- (instancetype)initWithAPIClient:(StartAPIClient *)apiClient
                             card:(StartCard *)card
                           amount:(NSInteger)amount
                         currency:(NSString *)currency
                     successBlock:(StartSuccessBlock)successBlock
                       errorBlock:(StartErrorBlock)errorBlock
                      cancelBlock:(StartCancelBlock)cancelBlock {
    self = [super init];
    if (self) {
        _apiClient = apiClient;

        _card = card;
        _amount = amount;
        _currency = currency.copy;

        _successBlock = [successBlock copy];
        _errorBlock = [errorBlock copy];
        _cancelBlock = [cancelBlock copy];
    }
    return self;
}

- (void)perform {
    [self createToken];
}

@end
