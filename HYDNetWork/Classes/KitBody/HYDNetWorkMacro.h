//
//  HYDNetWorkMacro.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYDRequestEnums.h"

//*****************************************域名---服务***************************************************//

#ifdef DEBUG
    static NSInteger kNetType  = 3;     // 2:生产服务  3:测试服务  4:UAT 5:自定义 （参考 HYDServiceEnvironmentType）
#else
    static NSInteger kNetType  = 2;     /*<<@@上线环境，正确值为2，请勿动@@>>*/
#endif


@interface HYDNetWorkMacro : NSObject

+ (HYDNetWorkMacro *)sharedNetWorkMacro;


/**
 设置全局的网络请求公共参数，若不设置默认没有。
 
 @param params 公共参数
 */
+ (void)setRequestCommonParams:(NSDictionary *)params;

/**
 设置全局的网络请求公共参数，若不设置默认为空。
 
 @param tokenId 标识用户的tokenId
 @param deviceCode 设备唯一标识ID
 */
+ (void)setRequestTokenId:(NSString *)tokenId deviceCode:(NSString *)deviceCode;

/**
 设置服务环境

 @param type 服务类型
 */
- (void)setUpWithServiceEnvironmentType:(HYDServiceEnvironmentType)type;

/**
 设置不同后台服务的host

 @param type 服务类型
 @param host host地址
 */
- (void)setUpWithUrlHostType:(HYDServiceType)type host:(NSString *)host;

/**
 获取后台

 @param type 服务类型
 @return host地址
 */
+ (NSString *)getUrlHostWithServiceType:(HYDServiceType)type;

/**
 获取环境类型

 @return 环境类型
 */
- (HYDServiceEnvironmentType)getCurrentServiceEnvironment;
@end
