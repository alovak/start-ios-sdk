//
//  NSNumber+Start.m
//  StartSDK
//
//  Created by drif on 11/27/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import "NSNumber+Start.h"

@implementation NSNumber (Start)

#pragma mark - Interface methods

- (BOOL)startIsBOOL {
    return [@(self.boolValue) isEqualToNumber:self];
}

@end
