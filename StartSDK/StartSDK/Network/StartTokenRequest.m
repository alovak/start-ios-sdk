//
//  StartTokenRequest.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import "StartTokenRequest.h"
#import "StartCard.h"
#import "StartTokenEntity.h"
#import "StartException.h"

@implementation StartTokenRequest {
    NSDictionary *_params;
    StartTokenEntity *_token;
}

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithCard:[[StartCard alloc] init]];
}

#pragma mark - PayfortAPIClientRequest protocol

- (NSString *)method {
    return @"POST";
}

- (NSString *)path {
    return @"tokens";
}

- (NSDictionary *)params {
    return _params;
}

- (id)response {
    return _token;
}

- (BOOL)processResponse:(NSDictionary *)response {
    @try {
        _token = [[StartTokenEntity alloc] initWithDictionary:response];
        return YES;
    }
    @catch (StartException *) {
        return NO;
    }
}

#pragma mark - Interface methods

- (instancetype)initWithCard:(StartCard *)card {
    self = [super init];
    if (self) {
        _params = @{
                @"name": card.cardholder,
                @"number": card.number,
                @"cvc": card.cvc,
                @"exp_month": @(card.expirationMonth),
                @"exp_year": @(card.expirationYear)
        };
    }
    return self;
}

@end
