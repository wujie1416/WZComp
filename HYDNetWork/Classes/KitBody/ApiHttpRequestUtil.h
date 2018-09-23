//
//  ApiHttpRequestUtil.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "APIRequestGenerator.h"

typedef void(^ApiHTTPRequestCallBack) (id response, NSURLRequest *request);

typedef void(^ApiHTTPRequestUploadCallBack) (NSProgress *uploadProgress);


@class ApiHttpRequestUtil;

/**
 *  网络请求回调代理
 */
@protocol ApiHttpRequestUtilDelegate <NSObject>
/**
 *  网络请求成功回调
 */
- (void)requestUtil:(ApiHttpRequestUtil *)util didGetSuccessResponse:(id)response andRequest:(NSURLRequest *)request;
/**
 *  网络请求失败回调
 */
- (void)requestUtil:(ApiHttpRequestUtil *)util didGetFailedResponse:(id)response andRequest:(NSURLRequest *)request;

@end


@interface ApiHttpRequestUtil : NSObject
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, assign) NSTimeInterval timeoutSeconds;
@property (nonatomic, assign) WZHttpRequestMethod requestMethod; // 默认为使用AFN发送网络请求
@property (nonatomic, weak) id <ApiHttpRequestUtilDelegate> requestDelegate; // 只有在非单例情况下才可以使用，否则会造成混乱

+ (instancetype)sharedInstance;

- (instancetype)initWithTimeoutInterval:(NSTimeInterval)time;

/**
 *  发送Get请求
 *
 *  @param params         请求输入参数
 *  @param methodName     请求路径不包含服务器地址的部分
 *  @param serviceType    指定请求地址类型，具体见定义
 *  @param contentType    http指定的content-type,具体见定义:https://en.wikipedia.org/wiki/Media_type
 *  @param success        请求成功回调
 *  @param fail           请求失败回调
 *
 *  @return 请求任务的taskIdentifier
 */
- (NSURLSessionDataTask *)callGETWithParams:(NSDictionary *)params
                                 methodName:(NSString *)methodName
                                serviceType:(HYDServiceType)serviceType
                                contentType:(WZhttpContentType)contentType
                                    success:(ApiHTTPRequestCallBack)success
                                       fail:(ApiHTTPRequestCallBack)fail;

/**
 *  发送Get请求
 *
 *  @param params         请求输入参数
 *  @param methodName     请求路径不包含服务器地址的部分
 *  @param serviceType    指定请求地址类型，具体见定义
 *  @param success        请求成功回调
 *  @param fail           请求失败回调
 *
 *  @return 请求任务的taskIdentifier
 */
- (NSURLSessionDataTask *)callGETWithParams:(NSDictionary *)params
                                 methodName:(NSString *)methodName
                                serviceType:(HYDServiceType)serviceType
                                    success:(ApiHTTPRequestCallBack)success
                                       fail:(ApiHTTPRequestCallBack)fail;

/**
 *  发送Post请求
 *
 *  @param params         请求输入参数
 *  @param methodName     请求路径不包含服务器地址的部分
 *  @param serviceType    指定请求地址类型，具体见定义
 *  @param contentType    http指定的content-type,具体见定义:https://en.wikipedia.org/wiki/Media_type
 *  @param success        请求成功回调
 *  @param fail           请求失败回调
 *
 *  @return 请求任务的taskIdentifier
 */
- (NSURLSessionDataTask *)callPOSTWithParams:(NSDictionary *)params
                                  methodName:(NSString *)methodName
                                 serviceType:(HYDServiceType)serviceType
                                 contentType:(WZhttpContentType)contentType
                                     success:(ApiHTTPRequestCallBack)success
                                        fail:(ApiHTTPRequestCallBack)fail;
/**
 *  发送Post请求
 *
 *  @param params         请求输入参数
 *  @param methodName     请求路径不包含服务器地址的部分
 *  @param serviceType    指定请求地址类型，具体见定义
 *  @param success        请求成功回调
 *  @param fail           请求失败回调
 *
 *  @return 请求任务的taskIdentifier
 */
- (NSURLSessionDataTask *)callPOSTWithParams:(NSDictionary *)params
                                  methodName:(NSString *)methodName
                                 serviceType:(HYDServiceType)serviceType
                                     success:(ApiHTTPRequestCallBack)success
                                        fail:(ApiHTTPRequestCallBack)fail;

/**
 *  发送Post请求 (默认还是针对发送请求加密，返回响应解密)
 *
 *  @param wholeUrl         完整的请求url
 *  @param params           请求参数
 *  @param extraParams      额外的请求参数，此参数是和jsonParams并列的参数字典（例如下面的age）
 *  @param success          请求成功回调
 *  @param fail             请求失败回调
 *
 *  @return 请求任务的taskIdentifier
     {
         age = 27;
         jsonParams = "6OpVk3LxHtiTVRi6uTWZgi/kg3B3lSJt11RxxbRGcFibTgauBp+oHsOAThuKE2ISTdGyDrz9zzXlONacBb88AV/CJTKzb372MnRNwLOr3h6RtnUAh3lJ0sJ8iKgNvd8TraySNxpJdQAbUcxatkAOBOW5ws3qDt5IdTk7J1gqFqgExwnEk2mIYDQRX7C1dPRuY7rqBGDPxNJy3wBZi4OaqmcD7O5c+iMyAIHSzSFqXTpLtHU+BlaaNUBB9br9KGk2";
     }
 */
- (NSURLSessionDataTask *)callPOSTWithUrl:(NSString *)wholeUrl
                                   params:(NSDictionary *)params
                           extraParams:(NSDictionary *)extraParams
                                  success:(ApiHTTPRequestCallBack)success
                                     fail:(ApiHTTPRequestCallBack)fail;

@end
