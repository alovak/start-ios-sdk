//
//  PayfortStart.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import "PayfortStart.h"
#import "PayfortToken.h"
#import "PayfortAPIClient.h"
#import "PayfortTokenRequest.h"
#import "PayfortCard.h"

NSErrorDomain const PayfortStartInternalError = @"PayfortStartInternalError";

@implementation PayfortStart {
    PayfortAPIClient *_apiClient;
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
        _apiClient = [[PayfortAPIClient alloc] initWithBase:@"https://api.start.payfort.com/" apiKey:apiKey];
    }
    return self;
}

- (void)createTokenForCard:(PayfortCard *)card
              successBlock:(PayfortStartSuccessBlock)successBlock
                errorBlock:(PayfortStartErrorBlock)errorBlock
               cancelBlock:(PayfortStartCancelBlock)cancelBlock {

    [_apiClient performRequest:[[PayfortTokenRequest alloc] initWithCard:card] successBlock:^(id <PayfortAPIClientRequest> request) {
        successBlock(request.response);
    } errorBlock:^(id <PayfortAPIClientRequest> request, NSError *error) {
        if (error.domain == PayfortAPIClientError) {
            error = [NSError errorWithDomain:PayfortStartInternalError code:0 userInfo:nil];
        }
        errorBlock(error);
    }];
}

@end
