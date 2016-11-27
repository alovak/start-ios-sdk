//
//  Start.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import "Start.h"
#import "StartToken.h"
#import "StartAPIClient.h"
#import "StartTokenRequest.h"
#import "StartCard.h"

NSErrorDomain const StartInternalError = @"StartInternalError";

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
        _apiClient = [[StartAPIClient alloc] initWithBase:@"https://api.start.payfort.com/" apiKey:apiKey];
    }
    return self;
}

- (void)createTokenForCard:(StartCard *)card
              successBlock:(StartSuccessBlock)successBlock
                errorBlock:(StartErrorBlock)errorBlock
               cancelBlock:(StartCancelBlock)cancelBlock {

    [_apiClient performRequest:[[StartTokenRequest alloc] initWithCard:card] successBlock:^(id <StartAPIClientRequest> request) {
        successBlock(request.response);
    } errorBlock:^(id <StartAPIClientRequest> request, NSError *error) {
        if (error.domain == StartAPIClientError) {
            error = [NSError errorWithDomain:StartInternalError code:0 userInfo:nil];
        }
        errorBlock(error);
    }];
}

@end
