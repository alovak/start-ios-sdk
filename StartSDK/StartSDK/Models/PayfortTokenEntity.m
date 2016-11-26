//
//  PayfortTokenEntity.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import "PayfortTokenEntity.h"
#import "PayfortException.h"

@implementation PayfortTokenEntity

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithDictionary:@{}];
}

#pragma mark - Interface methods

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        if (![dictionary[@"id"] isKindOfClass:[NSString class]]) {
            [[PayfortException exceptionWithName:PayfortExceptionTokenDataInvalid reason:nil userInfo:nil] raise];
        }
        _tokenId = dictionary[@"id"];

        if (![dictionary[@"verification_required"] isKindOfClass:[NSNumber class]]) {
            [[PayfortException exceptionWithName:PayfortExceptionTokenDataInvalid reason:nil userInfo:nil] raise];
        }
        _isVerificationRequired = [dictionary[@"verification_required"] boolValue];
    }
    return self;
}

@end
