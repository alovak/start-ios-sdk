//
//  StartUtilsTests.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+Start.h"

@interface StartUtilsTests : XCTestCase

@end

@implementation StartUtilsTests

#pragma mark - Interface methods

- (void)testDateUtils {
    XCTAssertEqual([NSDate dateWithTimeIntervalSince1970:0.0f].startYear, 1970);
    XCTAssertEqual([NSDate dateWithTimeIntervalSince1970:0.0f].startMonth, 1);
    XCTAssertEqual([NSDate dateWithTimeIntervalSince1970:31 * 24 * 3600].startMonth, 2);
}

@end
