//
//  ApiHttpRequestUtil.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "ApiHttpRequestUtil.h"
#import "APIURLResponse.h"

extern NSString *const kErrorDomain;

@interface ApiHttpRequestUtil ()

@end

@implementation ApiHttpRequestUtil{
    NSURLSessionDataTask *_currentDataTask;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ApiHttpRequestUtil *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ApiHttpRequestUtil alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _requestMethod = WZHttpRequestMethodAFN;
        _timeoutSeconds = kNetworkingTimeoutSeconds;
    }
    return self;
}

- (instancetype)initWithTimeoutInterval:(NSTimeInterval)time
{
    if (self = [self init]) {
        _timeoutSeconds = time;
    }
    return self;
}

- (void)dealloc
{
//    WZLogDebug(@"------------dealloc request.URL: %@ for %@", _currentDataTask.currentRequest.URL, _requestDelegate);
    [self.sessionManager.session invalidateAndCancel];
}


#pragma mark - public methods

- (NSURLSessionDataTask *)callGETWithParams:(NSDictionary *)params
                                 methodName:(NSString *)methodName
                                serviceType:(HYDServiceType)serviceType
                                contentType:(WZhttpContentType)contentType
                                    success:(ApiHTTPRequestCallBack)success
                                       fail:(ApiHTTPRequestCallBack)fail
{
    NSURLRequest *request = [[APIRequestGenerator sharedInstance] generateGETRequestWithParams:params methodName:methodName serviceType:serviceType contentType:contentType];
    WZLogInfo(@"++++++++++++++GET request.URL: %@ and param is:%@", request.URL, params);
    NSURLSessionDataTask *dataTask = [self callApiWithRequest:request serviceType:serviceType success:success fail:fail];
    return dataTask;
}

- (NSURLSessionDataTask *)callGETWithParams:(NSDictionary *)params
                                 methodName:(NSString *)methodName
                                serviceType:(HYDServiceType)serviceType
                                    success:(ApiHTTPRequestCallBack)success
                                       fail:(ApiHTTPRequestCallBack)fail
{
    return [self callGETWithParams:params methodName:methodName serviceType:serviceType contentType:ContentTypeUrlencoded success:success fail:fail];
}

- (NSURLSessionDataTask *)callPOSTWithParams:(NSDictionary *)params
                                  methodName:(NSString *)methodName
                                 serviceType:(HYDServiceType)serviceType
                                 contentType:(WZhttpContentType)contentType
                                     success:(ApiHTTPRequestCallBack)success
                                        fail:(ApiHTTPRequestCallBack)fail
{
    NSURLRequest *request = [[APIRequestGenerator sharedInstance] generatePOSTRequestWithParams:params methodName:methodName serviceType:serviceType contentType:contentType];
    WZLogInfo(@"++++++++++++++POST request.URL: %@ and param is:%@", request.URL, params);
    NSURLSessionDataTask *dataTask = [self callApiWithRequest:request serviceType:serviceType success:success fail:fail];
    return dataTask;
}

- (NSURLSessionDataTask *)callPOSTWithParams:(NSDictionary *)params
                                  methodName:(NSString *)methodName
                                 serviceType:(HYDServiceType)serviceType
                                     success:(ApiHTTPRequestCallBack)success
                                        fail:(ApiHTTPRequestCallBack)fail
{
    return [self callPOSTWithParams:params methodName:methodName serviceType:serviceType contentType:ContentTypeUrlencoded success:success fail:fail];
}

- (NSURLSessionDataTask *)callPOSTWithUrl:(NSString *)wholeUrl
                                   params:(NSDictionary *)params
                           extraParams:(NSDictionary *)extraParams
                                  success:(ApiHTTPRequestCallBack)success
                                     fail:(ApiHTTPRequestCallBack)fail
{
    NSMutableURLRequest *request = [[APIRequestGenerator sharedInstance] generatePOSTRequestWithWholeUrl:wholeUrl Params:params extraParams:extraParams];
    WZLogInfo(@"++++++++++++++POST request.URL: %@ and param is:%@", request.URL, params);
    NSURLSessionDataTask *dataTask = [self callApiWithRequest:request serviceType:ServiceTypeBase success:success fail:fail];
    return dataTask;
}


#pragma mark - private methods
/** 这个函数存在的意义在于，如果将来要把AFNetworking换掉，只要修改这个函数的实现即可。 */
- (NSURLSessionDataTask *)callApiWithRequest:(NSURLRequest *)request
                                 serviceType:(HYDServiceType)serviceType
                                     success:(ApiHTTPRequestCallBack)success
                                        fail:(ApiHTTPRequestCallBack)fail
{
    NSURLSessionDataTask *dataTask = nil;
    switch (_requestMethod) {
            case WZHttpRequestMethodAFN:
        {
            dataTask = [self callApiWithAFNRequest:request
                                       serviceType:serviceType
                                           success:success
                                              fail:fail];
        }
            break;
            
        default:
            break;
    }
    _currentDataTask = dataTask;
    return dataTask;
}

- (NSURLSessionDataTask *)callApiWithAFNRequest:(NSURLRequest *)request
                                    serviceType:(HYDServiceType)serviceType
                                        success:(ApiHTTPRequestCallBack)success
                                           fail:(ApiHTTPRequestCallBack)fail
{
    NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        //TODO: taskIdentifier可能重复问题
        NSNumber *requestID = @([dataTask taskIdentifier]);
        
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        if (error) {
            if (httpURLResponse.statusCode == 304) {//缓存中取数据，没有进行网络请求
                success ? success(nil, request) : nil;
                if ([_requestDelegate respondsToSelector:@selector(requestUtil:didGetSuccessResponse:andRequest:)]) {
                    [_requestDelegate requestUtil:self didGetSuccessResponse:nil andRequest:request];
                }
            }else{
                APIURLResponse *urlResponse = nil;
                if (serviceType == ServiceTypeSolo) {
                    urlResponse = [[APIURLResponse alloc] initWithNoDESResponseData:responseObject error:error requestId:requestID];
                } else {
                    urlResponse = [[APIURLResponse alloc] initWithResponseData:responseObject error:error requestId:requestID];
                }
                WZLogError(@"##########response request.URL: %@ failed  for %@ and error is %@", httpURLResponse.URL, _requestDelegate, error);
                fail ? fail(urlResponse, request) : nil;
                if ([_requestDelegate respondsToSelector:@selector(requestUtil:didGetFailedResponse:andRequest:)]) {
                    [_requestDelegate requestUtil:self didGetFailedResponse:urlResponse andRequest:request];
                }
            }
        } else {
            APIURLResponse *urlResponse = nil;
            if (serviceType == ServiceTypeSolo) {
                urlResponse = [[APIURLResponse alloc] initWithNoDESResponseData:responseObject error:error requestId:requestID];
            } else {
                urlResponse = [[APIURLResponse alloc] initWithResponseData:responseObject error:error requestId:requestID];
            }
            WZLogInfo(@"##########response request.URL: %@ for %@ and data is %@", httpURLResponse.URL, _requestDelegate, urlResponse.content);
            success ? success(urlResponse, request) : nil;
            if ([_requestDelegate respondsToSelector:@selector(requestUtil:didGetSuccessResponse:andRequest:)]) {
                [_requestDelegate requestUtil:self didGetSuccessResponse:urlResponse andRequest:request];
            }
        }
    }];
    
    [dataTask resume];
    
    return dataTask;
}

#pragma mark - Getter
- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = _timeoutSeconds;
        sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfig];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/plain", @"text/html", nil];
    }
    return _sessionManager;
}


@end
