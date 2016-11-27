//
//  Start.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

@import UIKit;

#import "Start.h"
#import "StartAPIClient.h"
#import "StartCard.h"
#import "StartOperation.h"

static NSString *const StartBase = @"https://api.start.payfort.com/";

NSErrorDomain const StartError = @"StartError";

@implementation Start {
    StartAPIClient *_apiClient;
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

    StartOperation *operation = [[StartOperation alloc] initWithAPIClient:_apiClient
                                                                     card:card
                                                                   amount:amount
                                                                 currency:currency
                                                             successBlock:successBlock
                                                               errorBlock:errorBlock
                                                              cancelBlock:cancelBlock];
    [operation perform];
}

@end
