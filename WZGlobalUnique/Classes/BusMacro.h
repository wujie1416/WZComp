//
//  BusMacro.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/23.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#ifndef BusMacro_h
#define BusMacro_h


//-------------------三方SDK的key------------------------

#define kAppStoreId          @"1154042584"

#define kTelPhoneNum         @"4000808000"

//敏识的APP_KEY
#define MinShi_appKey_dis  @"0f1627f1e1cefc8af8f6310701-uratpunat"
#define MinShi_appKey_test @"9N5Pb6JWKeJV6dNJrfFh2NBD"

//网络是否可达的域名
#define kReachHostName      @"www.baidu.com"


//-------------------业务相关的特殊含义常量---------------------

//#define kDeviceToken    @"hyd.deviceToken"   //推送的deviceToken
//#define kTokenId        @"hyd.tokenId"       //访问请求的tokenId
#define kCEDQueryCreditResultFailCountKey [NSString stringWithFormat:@"%@_WLDCreditFailCount",HYDUserModelManagerShared.userModel.userId]


//-------------------颜色常量---------------------

#define  kCEDThemeColor  RGBA(89,205,125,1.0f)
#define  kNSDThemeColor  RGBA(251,67,131,1.0f)
#define  kThemeColor     RGBA(27,108,250,1.0f)
#define  kBackColor      RGBA(245, 245, 245, 1)
#define  kclearColor     [UIColor clearColor]
#define  kwhiteColor     [UIColor whiteColor]
#define  kHYD20Font      kFont(20)
#define  kFont(size)     [UIFont systemFontOfSize:size]

//-------------------字符串常量替换---------------------

//正常返回 msg为空
#define NetMsgErrorShowMsg       @"信息错误，请重试"

//状态正常返回数据异常
#define NetDataErrorShowMsg      @"数据异常，请重试"

//请求超时
#define NetTimeoutErrorShowMsg   @"请求超时，请检查网络"

//服务器宕机或服务器异常
#define NetServerErrorShowMsg    @"服务器繁忙，请稍后再试"


//-------------------产品枚举类型---------------------

typedef NS_ENUM(NSUInteger, LoanType) {
    LoanTypeNone  = 0000, //公安认证
    LoanTypeJSD   = 1001, //即速贷
    LoanTypeSBD   = 1002, //社保贷
    LoanTypeGJJD  = 1004, //公积金贷
    LoanTypeNSD   = 1201, //女神贷
    LoanTypeCED   = 1202, //超E贷
    LoanTypeHCR   = 1101, //恒车融(车贷)
    LoanTypeZYD   = 1102, //中易贷(房贷)
    LoanTypeDX    = 2000, //电销贷
    LoanTypeNewJSD    = 1010, //新即速贷
    LoanTypeNewQD    = 1210, //新Q贷
};


#endif /* BusMacro_h */
