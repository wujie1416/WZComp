//
//  HYDRequestEnums.h
//  HC-HYD
//
//  Created by 老司机车 on 21/08/2017.
//  Copyright © 2017 cheyy. All rights reserved.
//

#ifndef HYDRequestEnums_h
#define HYDRequestEnums_h
#import <WZLogger/WZLogging.h>

static NSTimeInterval kNetworkingTimeoutSeconds = 30.0f;


typedef NS_ENUM(NSUInteger, APIURLResponseStatus)
{
    APIURLResponseStatusSuccess,        //作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的RTApiBaseManager来决定。
    APIURLResponseStatusErrorTimeout,
    APIURLResponseStatusErrorNoNetwork  // 默认除了超时以外的错误都是无网络错误。
};

//  请求类型
typedef NS_ENUM(NSUInteger, APIManagerRequestType) {
    APIManagerRequestTypeGet,
    APIManagerRequestTypePost,
    APIManagerRequestTypeUploadImage,
    APIManagerRequestTypeDelete
};

//  错误类型
typedef NS_ENUM(NSUInteger, APIManagerErrorType) {
    APIManagerErrorTypeDefault,         //  没有产生过API请求，默认状态
    APIManagerErrorTypeSuccess,         //  API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    APIManagerErrorTypeNoContent,       //  API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    APIManagerErrorTypeParamsError,     //  参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    APIManagerErrorTypeTimeout,         //  请求超时。APIProxy设置的是20秒超时，具体超时时间的设置请自己去看APIProxy的相关代码。
    APIManagerErrorTypeNoNetwork,       //  网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
    APIManagerErrorTypeUserNotLogin
};

typedef NS_ENUM(NSInteger, WZHttpRequestMethod){
    WZHttpRequestMethodAFN = 0, // 表示使用AFN发送HTTP请求
};

typedef NS_ENUM(NSInteger, HYDServiceType)
{
    ServiceTypeBase         = 0,            //恒易贷
    ServiceTypeJsd          = 1,            //极速贷
    ServiceTypeHelp         = 2,            //帮助中心
    ServiceTypeSolo         = 3,             //个贷接口
    ServiceTypeCustom       = 4              //自定义
};

typedef NS_ENUM(NSInteger, WZhttpContentType)
{
    ContentTypeUrlencoded    = 0,            //application/x-www-form-urlencoded
    ContentTypeJson          = 1,            //application/json
};

typedef NS_ENUM(NSInteger, HYDServiceEnvironmentType)
{
    ServiceEnvironmentTypeProduce     = 2,            //生产环境
    ServiceEnvironmentTypeTest        = 3,            //测试环境
    ServiceEnvironmentTypePre_release = 4,            //UAT环境
    ServiceEnvironmentTypeCustom      = 5,            //自定义环境
};


#endif /* HYDRequestEnums_h */
