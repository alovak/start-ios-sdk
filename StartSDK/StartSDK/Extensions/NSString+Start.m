//
//  NSString+Start.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import "NSString+Start.h"

@implementation NSString (Start)

#pragma mark - Interface methods

- (NSString *)startStringByRemovingCharactersInSet:(NSCharacterSet *)set {
    return [[self componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
}

@end
