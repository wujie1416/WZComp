//
//  APIURLResponse.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "APIURLResponse.h"
#import <WZDes/WZDes.h>

@interface APIURLResponse ()
@property (nonatomic, assign, readwrite) APIURLResponseStatus status;
@property (nonatomic, copy, readwrite) id content;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@end

@implementation APIURLResponse

#pragma mark - life cycle

static id static_result (NSString *dataStr)
{
    NSMutableDictionary *dict = nil;
    dataStr = [WZDes decryptWithText:dataStr isKey:DESKEY];
    if (dataStr.length > 0)
    {
        NSError *error;
        NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        dict             = [NSJSONSerialization JSONObjectWithData:jsonData
                                                           options:NSJSONReadingMutableContainers
                                                             error:&error];
        if (dict == nil || error) {
            WZLogError(@"decrypt response happen error and error is:%@", error);
        }
    }
    return dict;
}

- (instancetype)initWithResponseData:(NSData *)responseData status:(APIURLResponseStatus)status requestId:(NSNumber *)requestId{
    
    if (self = [super init]) {
        self.status = status;
        self.requestId = [requestId integerValue];
        if (responseData) {
            NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            self.content = static_result(result);
        } else {
            self.content = nil;
        }
    }
    return self;
}

- (instancetype)initWithResponseData:(NSData *)responseData error:(NSError *)error requestId:(NSNumber *)requestId{
    
    if (self = [super init]) {
        self.error = error;
        self.status = [self responseStatusWithError:error];
        self.requestId = [requestId integerValue];
        if (responseData) {
            NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            self.content = static_result(result);
        } else {
            self.content = nil;
        }
    }
    return self;
}

- (instancetype)initWithNoDESResponseData:(NSData *)responseData error:(NSError *)error requestId:(NSNumber *)requestId
{
    if (self = [super init]) {
        self.error = error;
        self.status = [self responseStatusWithError:error];
        self.requestId = [requestId integerValue];
        if (responseData) {
            NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSMutableDictionary *dict = nil;
            if (result.length > 0)
            {
                NSError *error;
                NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
                
                dict             = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&error];
                if (dict == nil || error) {
                    WZLogError(@"decrypt response happen error and error is:%@", error);
                }
            }
            self.content = dict;
        } else {
            self.content = nil;
        }
    }
    return self;
}

- (instancetype)initWithResponseStr:(NSString *)responseStr error:(NSError *)error requestId:(NSNumber *)requestId
{
    if (self = [super init]) {
        self.error = error;
        self.status = [self responseStatusWithError:error];
        self.requestId = [requestId integerValue];
        if (responseStr) {
            self.content = static_result(responseStr);
        } else {
            self.content = nil;
        }
    }
    return self;
}


#pragma mark - private methods
- (APIURLResponseStatus)responseStatusWithError:(NSError *)error
{
    if(error){// 除了超时以外，所有错误都当成是无网络
        
        if (error.code == NSURLErrorTimedOut) {
            return APIURLResponseStatusErrorTimeout;
        }
        
        return APIURLResponseStatusErrorNoNetwork;
    } else {
        return APIURLResponseStatusSuccess;
    }
}

@end
