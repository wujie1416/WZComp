//
//  WZCrashHandler.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/5/12.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZCrashHandler : NSObject

//手动记录一个错误信息上报到crash日志服务器
+ (void)manualRecodeErrorWithName:(NSString *)name reason:(NSString *)reason userInfo:(NSDictionary *)userInfo;

@end
