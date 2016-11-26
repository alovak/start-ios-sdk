//
//  NSString+Payfort.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import "NSString+Payfort.h"

@implementation NSString (Payfort)

#pragma mark - Interface methods

- (NSString *)payfortStringByRemovingCharactersInSet:(NSCharacterSet *)set {
    return [[self componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
}

@end
