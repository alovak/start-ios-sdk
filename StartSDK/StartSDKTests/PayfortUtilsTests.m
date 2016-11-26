//
//  PayfortUtilsTests.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+Payfort.h"

@interface PayfortUtilsTests : XCTestCase

@end

@implementation PayfortUtilsTests

#pragma mark - Interface methods

- (void)testDateUtils {
    XCTAssertEqual([NSDate dateWithTimeIntervalSince1970:0.0f].payfortYear, 1970);
    XCTAssertEqual([NSDate dateWithTimeIntervalSince1970:0.0f].payfortMonth, 1);
    XCTAssertEqual([NSDate dateWithTimeIntervalSince1970:31 * 24 * 3600].payfortMonth, 2);
}

@end
