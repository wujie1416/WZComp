//
//  APIRequestGenerator.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYDNetWorkMacro.h"

@interface APIRequestGenerator : NSObject
@property(nonatomic, strong) NSDictionary *commonParams;
+ (instancetype)sharedInstance;

/**
 *  生成Get请求
 *
 *  @param requestParams  请求输入参数，
 *  @param methodName     请求路径不包含服务器地址的部分
 *  @param serviceType    指定请求地址类型，具体见定义
 *  @param contentType    指定请求地址类型，具体见定义
 *
 *  @return NSURLRequest
 */
- (NSURLRequest *)generateGETRequestWithParams:(NSDictionary *)requestParams
                                    methodName:(NSString *)methodName
                                   serviceType:(HYDServiceType)serviceType
                                   contentType:(WZhttpContentType)contentType;


/**
 *  生成Post请求
 *
 *  @param requestParams  请求输入参数，
 *  @param methodName     请求路径不包含服务器地址的部分
 *  @param serviceType    指定请求地址类型，具体见定义
 *  @param contentType    指定请求地址类型，具体见定义
 *
 *  @return NSURLRequest
 */
- (NSURLRequest *)generatePOSTRequestWithParams:(NSDictionary *)requestParams
                                     methodName:(NSString *)methodName
                                    serviceType:(HYDServiceType)serviceType
                                    contentType:(WZhttpContentType)contentType;

/**
 *  生成Post请求
 *
 *  @param wholeUrl                完整的请求url，
 *  @param requestParams     请求输入参数
 *  @param extraParams   额外的请求参数，此参数是和jsonParams并集的参数字典
 *
 *  @return NSURLRequest
 */
- (NSMutableURLRequest *)generatePOSTRequestWithWholeUrl:(NSString *)wholeUrl
                                           Params:(NSDictionary *)requestParams
                                   extraParams:(NSDictionary *)extraParams;


/**
 *  生成Upload请求
 *
 *  @param  url         上传图片的地址，
 *  @param  block    生成上传图片数据的block
 *
 *  @return NSURLRequest
 */
- (NSURLRequest *)generateUpLoadRequestWithUrl:(NSString *)url
                     constructingBodyWithBlock:block;

@end
