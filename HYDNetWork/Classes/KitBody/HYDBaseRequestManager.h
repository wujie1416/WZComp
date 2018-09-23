//
//  HYDBaseRequestManager.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIURLResponse.h"
#import "HYDRequestProtocol.h"
#import "ApiHttpRequestUtil.h"
#import "APIModel.h"

extern NSString *const kNetLoadingMsg;
extern NSString *const kErrorDomain;
extern NSString *const kErrorMsgKey;
extern NSString *const kHYDTokenIdExpiredNotification;
extern NSString *const kHYDForceUpdateNotification;

@interface HYDBaseRequestManager : NSObject

/**
 *  初始化函数，默认传入delegate，如不使用delegate可使用block进行相应的处理
 */
- (id)initWithCallBackDelegate:(id<HYDBaseRequestManagerCallBackDelegate>)delegate;

/**
 *  入参合法性校验的提示信息，在子类manager中使用
 */
@property (nonatomic, copy) NSString *parameterErrorMsg;
/**
 *  相应数据的data信息，可直接在Controller中时候，使用频率极低，
 *  ps：不建议直接在controller中使用
 */
@property (nonatomic, copy) NSDictionary *retDict; //data dictionary
/**
 *  相应数据的完整model信息，可直接在Controller中时候，使用频率低
 */
@property (nonatomic, strong) APIModel *retModel;
/**
 *  该网络请求是否显示菊花
 *   默认：YES
 */
@property (nonatomic, assign) BOOL showHud;
/**
 *  网络请求回调delegate
 */
@property (nonatomic, weak) id <HYDBaseRequestManagerCallBackDelegate> callBackDelegate;
/**
 *  网络请求成功的block
 */
@property (nonatomic, copy) ApiHTTPRequestCallBack successBlock;
/**
 *  网络请求失败的block
 */
@property (nonatomic, copy) ApiHTTPRequestCallBack failBlock;

#pragma mark -- public method

/**
 *  发起网络请求
 */
- (void)startTask;

/**
 *  取消网络请求
 */
- (void)cancelTasks;

/**
 *  清除block，防止循环引用
 */
- (void)clearCompletionBlock;

/**
 *  reformer数据
 *
 *  @param reformer reformer 工具
 *
 *  @return 业务层需要的东西
 */
- (id)fetchDataWithReformer:(id <APIManagerCallbackDataReformer>)reformer;


#pragma mark -- subClass 需重载以下方法进行网络请求

/**
 *  网络请求方法名称（强制）
 */
- (NSString *)methodName;

/**
 *  网络请求url类型（不强制）
 *  默认为：ServiceTypeBase
 *  如果临时修改某单一接口地址, 使用这种方式可针对接口临时变换测试地址。
 - (HYDServiceType)serviceType
 {
     [[HYDNetWorkMacro sharedNetWorkMacro] setUpWithUrlHostType:ServiceTypeCustom host:@"http://192.168.11.23:8301"];
     return ServiceTypeCustom;
 }
 */
- (HYDServiceType)serviceType;

/**
 *  网络请求入参（不强制）
 *  默认为：nil
 */
- (NSDictionary *)inputParameter;

/**
 *  网络请求的超时时间（不强制）
 *  默认为：kNetworkingTimeoutSeconds(30s)
 */
- (NSTimeInterval)timeoutInterval;

/**
 *  网络请求类型（不强制）
 *  默认为：APIManagerRequestTypePost
 */
- (APIManagerRequestType)requestType;

/**
 *  自定义设置http请求的content-type（不强制）
 *  默认为：application/x-www-form-urlencoded
 */
- (WZhttpContentType)contentType;

/**
 *  网络请求入参合法校验回调（不强制）
 *  默认为：YES
 */
- (BOOL)isInputParameterValid;

/**
 *  针对同一个manager网络请求，上一次request若没有返回，不许发起下一次的request（不强制）
 *  默认为：YES
 */
- (BOOL)isAvoidDoubleRequest;

/**
 *  子类manager对响应数据进行正确性校验,并可格式化处理。(建议重载)
 *  如果正确返回nil，错误返回相应的error信息
 *  默认为：nil
 */
- (NSError *)isResponseError:(APIURLResponse *)response;


@end
