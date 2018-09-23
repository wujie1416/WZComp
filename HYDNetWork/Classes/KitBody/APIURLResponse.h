//
//  APIURLResponse.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYDNetWorkMacro.h"

@interface APIURLResponse : NSObject

@property (nonatomic, assign, readonly) APIURLResponseStatus status;
@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, copy, readonly) id content;
@property (nonatomic, assign, readonly) NSInteger requestId;

- (instancetype)initWithResponseData:(NSData *)responseData status:(APIURLResponseStatus)status requestId:(NSNumber *)requestId;
- (instancetype)initWithResponseData:(NSData *)responseData error:(NSError *)error requestId:(NSNumber *)requestId;
- (instancetype)initWithNoDESResponseData:(NSData *)responseData error:(NSError *)error requestId:(NSNumber *)requestId;

//针对一个相应字符串进行解析（兼容webService 的返回结果）
- (instancetype)initWithResponseStr:(NSString *)responseStr error:(NSError *)error requestId:(NSNumber *)requestId;

@end
