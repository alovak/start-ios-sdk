//
//  StartVerificationRequest.m
//  StartSDK
//
//  Created by drif on 11/27/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import "StartVerificationRequest.h"
#import "StartTokenEntity.h"
#import "StartVerification.h"
#import "StartException.h"

@implementation StartVerificationRequest {
    NSString *_method;
    NSString *_path;
    NSDictionary *_params;
    StartVerification *_verification;
}

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithToken:[[StartTokenEntity alloc] init] amount:0 currency:@"" method:@""];
}

#pragma mark - PayfortAPIClientRequest protocol

- (NSString *)method {
    return _method;
}

- (NSString *)path {
    return _path;
}

- (NSDictionary *)params {
    return [_method isEqualToString:@"POST"] ? _params : nil;
}

- (id)response {
    return _verification;
}

- (BOOL)processResponse:(NSDictionary *)response {
    @try {
        _verification = [[StartVerification alloc] initWithDictionary:response];
        return YES;
    }
    @catch (StartException *) {
        return NO;
    }
}

#pragma mark - Interface methods

- (instancetype)initWithToken:(StartTokenEntity *)token
                       amount:(NSInteger)amount
                     currency:(NSString *)currency
                       method:(NSString *)method {
    self = [super init];
    if (self) {
        _method = method.copy;
        _path = [NSString stringWithFormat:@"tokens/%@/verification", token.tokenId];
        _params = @{
                @"amount": @(amount),
                @"currency": currency
        };
    }
    return self;
}

@end
