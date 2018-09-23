//
//  HYDBaseRequestManager.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "HYDBaseRequestManager.h"
#import "MBProgressHUD+WZ.h"
#import "WZReachability.h"

NSString *const kErrorDomain = @"com.hyd.apiManager";
NSString *const kErrorMsgKey = @"errMsg";
NSString *const kParameterInvalideMsg = @"input parameter is invalide";
NSString *const kNetNotReachabilityMsg = @"network not be reachability!";
NSString *const kNetLoadingMsg = @"加载中...";

NSString *const kHYDTokenIdExpiredNotification = @"kHYDTokenIdExpiredNotification";
NSString *const kHYDForceUpdateNotification = @"kHYDForceUpdateNotification";

@interface HYDBaseRequestManager()<ApiHttpRequestUtilDelegate>
@property (nonatomic, copy, readwrite) NSDictionary *fetchedRawData;
@property (nonatomic, strong) NSMutableDictionary *dictRequestTask;
@end

@implementation HYDBaseRequestManager
{
    BOOL _isRequesting;//同一请求未完成时，避免多次发送
}

- (instancetype)init
{
    if (self = [super init]) {
        _parameterErrorMsg = nil;
        _retModel = [APIModel new];
    }
    return self;
}

- (id)initWithCallBackDelegate:(id<HYDBaseRequestManagerCallBackDelegate>)delegate
{
    if (self = [super init]) {
        _parameterErrorMsg = nil;
        _retModel = [APIModel new];
        _callBackDelegate = delegate;
        _showHud = YES;
    }
    return self;
}


- (void)dealloc
{
    if (_showHud) [MBProgressHUD hideHUD];
    [self cancelTasks];
}


- (void)startTask
{
    //判断是否存在上一次的请求没有返回的情况
    if (_isRequesting && [self isAvoidDoubleRequest]) {
        return;
    }
    
    // 获取实际的methodName
    NSString *methodName = [self methodName];
    
    // 获取实际的请求url类型， 默认使用LEServiceTypeBase
    HYDServiceType serviceType = [self serviceType];
    
    //网络请求类型
    APIManagerRequestType requestType = [self requestType];
    
    // 针对入参进行合法性校验
    BOOL inputValide = [self isInputParameterValid];
    if (inputValide) {
        if ([self isReachable]) {
            //保护防止重复请求
            if (_showHud) [MBProgressHUD showWithMessage:kNetLoadingMsg];
            _isRequesting = YES;
            
            //开始请求
            NSDictionary *inputDict = [self inputParameter];// 获取实际的输入参数
            ApiHttpRequestUtil *requestUtil = [[ApiHttpRequestUtil alloc] initWithTimeoutInterval:[self timeoutInterval]];
            requestUtil.requestDelegate = self;
            NSURLSessionDataTask *task = nil;
            switch (requestType) {
                case APIManagerRequestTypeGet:
                {
                    task = [requestUtil callGETWithParams:inputDict methodName:methodName serviceType:serviceType contentType:[self contentType] success:^(id response, NSURLRequest *request) {
                        _successBlock ? _successBlock(response, request) : nil;
                        _isRequesting = NO;
                    } fail:^(id response, NSURLRequest *request) {
                        _failBlock ? _failBlock(response, request) : nil;
                        _isRequesting = NO;
                    }];
                }
                    break;
                case APIManagerRequestTypePost:
                {
                    task = [requestUtil callPOSTWithParams:inputDict methodName:methodName serviceType:serviceType contentType:[self contentType] success:^(id response, NSURLRequest *request) {
                        _successBlock ? _successBlock(response, request) : nil;
                    } fail:^(id response, NSURLRequest *request) {
                        _failBlock ? _failBlock(response, request) : nil;
                    }];
                }
                    break;
                default:
                {
                    WZLogError(@"request Type has no define!");
                }
            }
            [self.dictRequestTask setObject:task forKey:@(task.taskIdentifier)];
        } else {
            self.retModel.showMsg = @"网络不通，请检查您的网络连接!";
            NSError *err = [[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeNoNetwork userInfo:@{kErrorMsgKey:kNetNotReachabilityMsg}];
            [self internalCallBackDelegateFailedWithError:err];
        }
    } else {
        NSError *err = [[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeParamsError userInfo:@{kErrorMsgKey:_parameterErrorMsg?:kParameterInvalideMsg}];
        self.retModel.showMsg = @"请您输入合法参数！";
        [self internalCallBackDelegateFailedWithError:err];
    }
}

- (void)clearCompletionBlock
{
    self.successBlock = nil;
    self.failBlock = nil;
}

- (void)cancelTasks
{
    for (NSURLSessionDataTask *task in [self.dictRequestTask allValues]) {
        if (task.state != NSURLSessionTaskStateCompleted && task.state != NSURLSessionTaskStateCanceling) {
            WZLogInfo(@"#### task:%@ canceled!!!!", task.currentRequest.URL);
            [task cancel];
        }
    }
    [self.dictRequestTask removeAllObjects];
}


- (id)fetchDataWithReformer:(id<APIManagerCallbackDataReformer>)reformer
{
    id resultData = nil;
    if ([reformer conformsToProtocol:@protocol(APIManagerCallbackDataReformer)]) {
        resultData = [reformer manager:self reformData:self.fetchedRawData];
    } else {
        resultData = self.fetchedRawData;
    }
    return resultData;
}

#pragma mark - netRequsetResult
- (void)internalCallBackDelegateFailedWithError:(NSError *)err
{
    if ([_callBackDelegate respondsToSelector:@selector(manager:didFailedWithError:)]) {
        WZLogError(@"%@_%@(%@) failed, and error info is: %@", [_callBackDelegate class], [self class], [self methodName], err.userInfo);
        [_callBackDelegate manager:self didFailedWithError:err];
    }
}

- (void)internalCallBackDelegateSuccessWithResponse:(APIURLResponse *)urlResponse;
{
    if ([_callBackDelegate respondsToSelector:@selector(manager:didSuccessWithResponse:)]) {
        [_callBackDelegate manager:self didSuccessWithResponse:urlResponse];
    }
}

#pragma mark - ApiHttpRequestUtilDelegate
- (void)requestUtil:(ApiHttpRequestUtil *)util didGetSuccessResponse:(id)response andRequest:(NSURLRequest *)request
{
    if (_showHud) [MBProgressHUD hideHUD];
    _isRequesting = NO;
    //1.校验格式
    if (response == nil || [response isKindOfClass:[APIURLResponse class]] == NO) {
        NSError *err = [[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeDefault userInfo:@{kErrorMsgKey:[NSString stringWithFormat:@"%@ response is not APIURLResponse", self.class]}];
        [self internalCallBackDelegateFailedWithError:err];
        return;
    }
    
    APIURLResponse *urlResponse = (APIURLResponse *)response;
    self.fetchedRawData = urlResponse.content;
    
    //2.校验返回数据合法性
    NSError *err = nil;
    if (urlResponse.status == APIURLResponseStatusSuccess) {
        if (urlResponse.content == nil || [urlResponse.content isKindOfClass:[NSNull class]] ) {
            err = [[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeNoContent userInfo:@{kErrorMsgKey:@"response.content is NULL"}];
            self.retModel.showMsg = @"服务维护中，请稍后再试！";
        }
    } else {
        err = [[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeNoContent userInfo:@{kErrorMsgKey:@"response.status is not APIURLResponseStatusSuccess"}];
    }

    if (err) {
        [self internalCallBackDelegateFailedWithError:err];
       return;
    }
    
    //3.校验特殊code码
    NSInteger rspCode = [self.fetchedRawData[@"rspCode"] integerValue];
    if (rspCode == 501 || rspCode == 502) { //501 tokenId过期，需要重新登录   502账号不存在
        [[NSNotificationCenter defaultCenter] postNotificationName:kHYDTokenIdExpiredNotification object:self.fetchedRawData[@"showMsg"]?:@""];
        err = [[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeUserNotLogin userInfo:@{kErrorMsgKey:self.fetchedRawData.description}];
        [self internalCallBackDelegateFailedWithError:err];
        return;
    } else if (rspCode == 407) { //提示需要用户 强制升级
        [[NSNotificationCenter defaultCenter] postNotificationName:kHYDForceUpdateNotification object:self.fetchedRawData[@"showMsg"]?:@""];
        err = [[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeUserNotLogin userInfo:@{kErrorMsgKey:self.fetchedRawData.description}];
        [self internalCallBackDelegateFailedWithError:err];
        return;
    }
    //4.子类校验数据有效性
    err = [self isResponseError:urlResponse];
    if (err) {
        [self internalCallBackDelegateFailedWithError:err];
        return;
    }
    
    // 5.最后，说明是正确返回数据
    [self internalCallBackDelegateSuccessWithResponse:urlResponse];
}

- (void)requestUtil:(ApiHttpRequestUtil *)util didGetFailedResponse:(id)response andRequest:(NSURLRequest *)request
{
    if (_showHud) [MBProgressHUD hideHUD];
    _isRequesting = NO;
    
    NSError *err = nil;
    APIURLResponse *urlResponse = (APIURLResponse *)response;
    WZLogError(@"failed:%@", urlResponse.error);
    self.fetchedRawData = urlResponse.content;
    switch (urlResponse.status) {
        case APIURLResponseStatusErrorTimeout:
        {
            err = [[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeTimeout userInfo:@{kErrorMsgKey:urlResponse.error.localizedDescription}];
        }
        break;
        
        case APIURLResponseStatusErrorNoNetwork:
        {
            err = [[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeNoNetwork userInfo:@{kErrorMsgKey:urlResponse.error.localizedDescription}];
        }
        break;
        
        default:
        {
            if (((APIURLResponse *)response).error) {
                err = ((APIURLResponse *)response).error;
            } else {
                err = [[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeDefault userInfo:@{kErrorMsgKey:[NSString stringWithFormat:@"%@ request failed", self.class]}];
            }
        }
        break;
    }
    self.retModel.showMsg = @"请求超时，请检查网络";
    [self internalCallBackDelegateFailedWithError:err];
}

#pragma mark - Getter
- (NSMutableDictionary *)dictRequestTask
{
    if (nil == _dictRequestTask) {
        _dictRequestTask = [NSMutableDictionary dictionary];
    }
    return _dictRequestTask;
}

- (BOOL)isReachable
{
    return [WZReachability reachabilityWithHostname:@"www.baidu.com"].reachable;
}

#pragma mark -- subClass 需重载以下方法进行网络请求

- (NSString *)methodName {
    NSAssert(0, @"methodName is null! and subclass %@ must be reload this method!",[self class]);
    return @"";
}

- (HYDServiceType)serviceType {
    return ServiceTypeBase;
}

- (NSDictionary *)inputParameter {
    return nil;
}

- (NSTimeInterval)timeoutInterval {
    return kNetworkingTimeoutSeconds;
}

- (APIManagerRequestType)requestType {
    return APIManagerRequestTypePost;
}

- (WZhttpContentType)contentType {
    return ContentTypeUrlencoded;
}

- (BOOL)isInputParameterValid {
    return YES;
}

- (BOOL)isAvoidDoubleRequest {
    return YES;
}

- (NSError *)isResponseError:(APIURLResponse *)response {
    return nil;
}

@end
