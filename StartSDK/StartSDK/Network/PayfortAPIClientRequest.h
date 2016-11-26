//
//  PayfortAPIClientRequest.h
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PayfortAPIClientRequest <NSObject>

@property (nonatomic, copy, readonly) NSString *method;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSDictionary *params;
@property (nonatomic, strong, readonly) id response;

- (BOOL)processResponse:(NSDictionary *)response;

@end

NS_ASSUME_NONNULL_END
