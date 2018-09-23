//
//  APIModel.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "APIModel.h"

@implementation APIModel

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic{
    NSString *showMsg = dic[@"showMsg"];
    if (showMsg == nil || [showMsg isKindOfClass:[NSNull class]] || showMsg.length == 0) {
        self.showMsg = @"服务器接口异常，稍后再试~";
    }
    return YES;
}


@end
