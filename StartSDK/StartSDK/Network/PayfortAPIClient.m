//
//  PayfortAPIClient.m
//  StartSDK
//
//  Created by drif on 11/26/16.
//  Copyright © 2016 Payfort (http://payfort.com). All rights reserved.
//

#import "PayfortAPIClient.h"
#import "PayfortAPIClientRequest.h"

NSErrorDomain const PayfortAPIClientError = @"PayfortAPIClientError";

@implementation PayfortAPIClient {
    NSString *_base;
    NSString *_authorization;
}

#pragma mark - Private methods

- (void)performURLRequest:(NSURLRequest *)urlRequest
                  request:(id <PayfortAPIClientRequest>)request
             successBlock:(PayfortAPIClientSuccessBlock)successBlock
               errorBlock:(PayfortAPIClientErrorBlock)errorBlock {

    NSURLSessionDataTask *dataTask = [NSURLSession.sharedSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleRequest:request response:response data:data error:error successBlock:successBlock errorBlock:errorBlock];
    }];
    [dataTask resume];
}

- (void)handleRequest:(id <PayfortAPIClientRequest>)request
             response:(NSURLResponse *)response
                 data:(NSData *)data
                error:(NSError *)error
         successBlock:(PayfortAPIClientSuccessBlock)successBlock
           errorBlock:(PayfortAPIClientErrorBlock)errorBlock {

    if (error) {
        errorBlock(request, error);
    }
    else {
        id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([responseJSON isKindOfClass:[NSDictionary class]]) {
            if ([response isKindOfClass:[NSHTTPURLResponse class]] && ((NSHTTPURLResponse *)response).statusCode / 100 == 2) {
                if ([request processResponse:responseJSON]) {
                    successBlock(request);
                }
                else {
                    errorBlock(request, [NSError errorWithDomain:PayfortAPIClientError code:PayfortAPIClientErrorCodeInvalidResponse userInfo:nil]);
                }
            }
            else {
                errorBlock(request, [NSError errorWithDomain:PayfortAPIClientError code:PayfortAPIClientErrorCodeServerError userInfo:nil]);
            };
        }
        else {
            errorBlock(request, [NSError errorWithDomain:PayfortAPIClientError code:PayfortAPIClientErrorCodeInvalidResponse userInfo:nil]);
        }
    }
}

#pragma mark - NSObject methods

- (instancetype)init {
    // overriding designated initializer of superclass
    return [self initWithBase:@"" apiKey:@""];
}

#pragma mark - Interface methods

- (instancetype)initWithBase:(NSString *)base apiKey:(NSString *)apiKey {
    self = [super init];
    if (self) {
        _base = base.copy;

        NSString *base64Key = [[apiKey dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        _authorization = [@"Basic " stringByAppendingString:base64Key];
    }
    return self;
}

- (void)performRequest:(id <PayfortAPIClientRequest>)request
          successBlock:(PayfortAPIClientSuccessBlock)successBlock
            errorBlock:(PayfortAPIClientErrorBlock)errorBlock {

    NSURL *url = [NSURL URLWithString:[_base stringByAppendingString:request.path]];

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:request.method];
    [urlRequest addValue:_authorization forHTTPHeaderField:@"Authorization"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSData *jsonData;
    @try {
        jsonData = [NSJSONSerialization dataWithJSONObject:request.params options:0 error:nil];
    }
    @catch (NSException *) {
        errorBlock(request, [NSError errorWithDomain:PayfortAPIClientError code:PayfortAPIClientErrorCodeCantFormJSON userInfo:nil]);
        return;
    }
    [urlRequest setHTTPBody:jsonData];

    [self performURLRequest:urlRequest request:request successBlock:successBlock errorBlock:errorBlock];
}

@end
