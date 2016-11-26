//
//  NSDate+Payfort.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import "NSDate+Payfort.h"

@implementation NSDate (Payfort)

#pragma mark - Interface methods

- (NSInteger)payfortYear
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    return [calendar component:NSCalendarUnitYear fromDate:self];
}

- (NSInteger)payfortMonth
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    return [calendar component:NSCalendarUnitMonth fromDate:self];
}

@end
