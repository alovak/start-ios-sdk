//
//  PayfortCardBrandDetector.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import "PayfortCardBrandDetector.h"
#import "PayfortCard.h"

@implementation PayfortCardBrandDetector {
    NSArray *_prefixes;
    NSArray *_lengths;
}

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithPrefixes:@[] lengths:@[]];
}

#pragma mark - Interface methods

- (instancetype)initWithPrefixes:(NSArray *)prefixes lengths:(NSArray *)lengths {
    self = [super init];
    if (self) {
        _prefixes = prefixes.copy;
        _lengths = lengths.copy;
    }
    return self;
}

- (BOOL)isContainingCard:(PayfortCard *)card {

    if (![_lengths containsObject:@(card.number.length)]) {
        return NO;
    }

    for (NSString *prefix in _prefixes) {
        if ([card.number hasPrefix:prefix]) {
            return YES;
        }
    }

    return NO;
}

@end
