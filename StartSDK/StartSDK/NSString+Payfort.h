//
//  NSString+Payfort.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Payfort)

- (NSString *)payfortStringByRemovingCharactersInSet:(NSCharacterSet *)set;

@end

NS_ASSUME_NONNULL_END
