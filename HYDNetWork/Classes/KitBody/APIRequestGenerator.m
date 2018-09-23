//
//  APIRequestGenerator.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "APIRequestGenerator.h"
#import <AFNetworking/AFNetworking.h>
#import <WZDes/WZDes.h>

@interface APIRequestGenerator ()
@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;
@property (nonatomic, strong) AFJSONRequestSerializer *jsonSerializer;
@end

@implementation APIRequestGenerator

#pragma mark - public methods
+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    static APIRequestGenerator *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[APIRequestGenerator alloc] init];
        sharedInstance.commonParams = @{@"sourceType":@"2",
                                                                      @"utmCode":@"201",
                                                                      @"osVersion":[NSString stringWithFormat:@"iOS_%@", [UIDevice currentDevice].systemVersion],
                                                                      @"version":[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                                                      @"deviceCode":@"",//待赋值
                                                                      @"tokenId":@"",};//待赋值
    });
    return sharedInstance;
}

#pragma mark - getters and setters
- (void)setCommonParams:(NSDictionary *)commonParams
{
    NSMutableDictionary *totalParam = [[NSMutableDictionary alloc] initWithDictionary:_commonParams];
    [totalParam addEntriesFromDictionary:commonParams];
    _commonParams = [NSDictionary dictionaryWithDictionary:totalParam];
}

- (AFHTTPRequestSerializer *)httpRequestSerializer
{
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        /*如果用last-modified则需要把cachePolicy设置成NSURLRequestReloadIgnoringLocalCacheData
          _httpRequestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;*/
        _httpRequestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    }
    return _httpRequestSerializer;
}

- (AFJSONRequestSerializer *)jsonSerializer
{
    if (_jsonSerializer == nil) {
        _jsonSerializer = [AFJSONRequestSerializer serializer];
        /*如果用last-modified则需要把cachePolicy设置成NSURLRequestReloadIgnoringLocalCacheData
         _httpRequestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;*/
        _jsonSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    }
    return _jsonSerializer;
}

- (NSURLRequest *)generateGETRequestWithParams:(NSDictionary *)requestParams
                                    methodName:(NSString *)methodName
                                   serviceType:(HYDServiceType)serviceType
                                   contentType:(WZhttpContentType)contentType
{
    NSDictionary *finalParam = [self generateFinalParams:requestParams serviceType:serviceType];
    NSString *urlString = [[self getServiceUrlWithServiceType:serviceType] stringByAppendingString:methodName];
    NSMutableURLRequest *request = nil;
    if (contentType == ContentTypeJson) {
        request = [self.jsonSerializer requestWithMethod:@"GET" URLString:urlString parameters:finalParam error:NULL];
    } else {
        request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:urlString parameters:finalParam error:NULL];
    }
    NSMutableDictionary *header = [NSMutableDictionary dictionaryWithDictionary:request.allHTTPHeaderFields];
    [header setObject:[self generateFinalHeader] forKey:@"common-params"];
    request.allHTTPHeaderFields = header;
    return request;
}

- (NSURLRequest *)generatePOSTRequestWithParams:(NSDictionary *)requestParams
                                     methodName:(NSString *)methodName
                                    serviceType:(HYDServiceType)serviceType
                                    contentType:(WZhttpContentType)contentType
{
    NSDictionary *finalParam = [self generateFinalParams:requestParams serviceType:serviceType];
    NSString *urlString = [[self getServiceUrlWithServiceType:serviceType] stringByAppendingString:methodName];
    NSMutableURLRequest *request = nil;
    if (contentType == ContentTypeJson) {
        request = [self.jsonSerializer requestWithMethod:@"POST" URLString:urlString parameters:finalParam error:NULL];
    } else {
         request = [self.httpRequestSerializer requestWithMethod:@"POST" URLString:urlString parameters:finalParam error:NULL];
    }
    NSMutableDictionary *header = [NSMutableDictionary dictionaryWithDictionary:request.allHTTPHeaderFields];
    [header setObject:[self generateFinalHeader] forKey:@"common-params"];
    request.allHTTPHeaderFields = header;
    return request;
}

- (NSMutableURLRequest *)generatePOSTRequestWithWholeUrl:(NSString *)wholeUrl
                                                  Params:(NSDictionary *)requestParams
                                             extraParams:(NSDictionary *)extraParams
{
    NSDictionary *finalParam = [self generateFinalParams:requestParams];
    if (extraParams && extraParams.count >0) {
       NSMutableDictionary  *newFinalParam = [[NSMutableDictionary alloc] initWithDictionary:finalParam];
        [newFinalParam addEntriesFromDictionary:extraParams];
        [newFinalParam setObject:finalParam[@"jsonParams"] forKey:@"state"];//为了兼容统一登录平台需求的后台（中杰做的）
        finalParam = newFinalParam;
    }
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"POST" URLString:wholeUrl parameters:finalParam error:NULL];
    NSMutableDictionary *header = [NSMutableDictionary dictionaryWithDictionary:request.allHTTPHeaderFields];
    [header setObject:[self generateFinalHeader] forKey:@"common-params"];
    request.allHTTPHeaderFields = header;
    return request;
}

- (NSURLRequest *)generateUpLoadRequestWithUrl:(NSString *)url
                                    constructingBodyWithBlock:block{
    NSMutableURLRequest *request = [self.httpRequestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:[self generateFinalParams:nil] constructingBodyWithBlock:block error:NULL];
    NSMutableDictionary *header = [NSMutableDictionary dictionaryWithDictionary:request.allHTTPHeaderFields];
    [header setObject:[self generateFinalHeader] forKey:@"common-params"];
    request.allHTTPHeaderFields = header;
    return request;
}

#pragma mark - inline method

- (NSDictionary *)generateFinalParams:(NSDictionary *)requestParams
{
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithDictionary:self.commonParams];
    if (requestParams) {
        [allParams addEntriesFromDictionary:requestParams];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:allParams options:NSJSONWritingPrettyPrinted error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString * signatureStr = [WZDes encryptWithText:json isKey:DESKEY];
    return @{@"jsonParams":signatureStr};
}

- (NSDictionary *)generateFinalParams:(NSDictionary *)requestParams serviceType:(HYDServiceType)serviceType
{
    if (serviceType == ServiceTypeSolo) {
        return requestParams;
    } else {
        return [self generateFinalParams:requestParams];
    }
}


- (NSString *)generateFinalHeader
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.commonParams options:0 error:nil];
    return  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]?:@"";
}


- (NSString *)getServiceUrlWithServiceType:(HYDServiceType)serviceType
{
    NSString *serviceUrl = [HYDNetWorkMacro getUrlHostWithServiceType:serviceType];
    return serviceUrl;
}


@end
