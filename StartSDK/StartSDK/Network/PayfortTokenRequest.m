//
//  PayfortTokenRequest.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import "PayfortTokenRequest.h"
#import "PayfortCard.h"
#import "PayfortTokenEntity.h"
#import "PayfortException.h"

@implementation PayfortTokenRequest {
    PayfortCard *_card;
    PayfortTokenEntity *_token;
}

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithCard:[[PayfortCard alloc] init]];
}

#pragma mark - PayfortAPIClientRequest protocol

- (NSString *)method {
    return @"POST";
}

- (NSString *)path {
    return @"tokens/";
}

- (NSDictionary *)params {
    return @{
            @"name": _card.cardholder,
            @"number": _card.number,
            @"cvc": _card.cvc,
            @"exp_month": @(_card.expirationMonth),
            @"exp_year": @(_card.expirationYear)
    };
}

- (id)response {
    return _token;
}

- (BOOL)processResponse:(NSDictionary *)response {
    @try {
        _token = [[PayfortTokenEntity alloc] initWithDictionary:response];
        return YES;
    }
    @catch (PayfortException *) {
        return NO;
    }
}

#pragma mark - Interface methods

- (instancetype)initWithCard:(PayfortCard *)card {
    self = [super init];
    if (self) {
        _card = card;
    }
    return self;
}

@end
