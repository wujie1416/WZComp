//
//  WZCompBaseWebViewController.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/29.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "WZWebViewController.h"
#import "HYDCompBaseController.h"
//urlMap字典中，h5页面url的key值
#define kh5Url @"url"

@interface WZCompBaseWebViewController : WZWebViewController

//公共参数
@property (nonatomic, copy, readonly) NSString *loanId;
@property (nonatomic, assign, readonly) LoanType loanType;
@property (nonatomic, copy, readonly) NSString *flowId;
@property (nonatomic, copy, readonly) NSString *unitCode;
@property (nonatomic, copy, readonly) NSDictionary *urlMap;
@property (nonatomic, copy, readonly) void(^completedBlock)(BOOL result,id data);

/**
 初始化方法——无需flowId
 
 @param loanType 产品类型
 @param loanId 产品Id
 @param unitCode 组件的编码
 @param block 回调方法
 @return 实例
 */
- (id)initWithLoanType:(LoanType)loanType loanId:(NSString *)loanId unitCode:(NSString *)unitCode completedBlock:(void(^)(BOOL result, id data))block;

/**
 初始化方法——无需urlMap

 @param loanType 产品类型
 @param loanId 产品Id
 @param flowId 流程Id
 @param unitCode 组件的编码
 @param block 回调方法
 @return 实例
 */
- (id)initWithLoanType:(LoanType)loanType loanId:(NSString *)loanId flowId:(NSString *)flowId unitCode:(NSString *)unitCode completedBlock:(void(^)(BOOL result, id data))block;

/**
 初始化方法——全量参数
 
 @param loanType 产品类型
 @param loanId 产品Id
 @param flowId 流程Id
 @param unitCode 组件的编码
 @param urlMap 组件需要的url，如H5页面的url(key:kh5Url)、组件内部调用接口的url(key:需要每个组件自己定义key，暂时没有这样的情况)
 @param block 回调方法
 @return 实例
 */
- (id)initWithLoanType:(LoanType)loanType loanId:(NSString *)loanId flowId:(NSString *)flowId unitCode:(NSString *)unitCode urlMap:(NSDictionary *)urlMap completedBlock:(void(^)(BOOL result, id data))block;


/**
 执行下一步流程
 
 @param data 回传数据
 */
- (void)nextStepWithData:(id)data;

/**
 初始化webViewController
 
 @param title 导航栏标题
 @param webUrl 请求的链接地址
 @return 示例
 */
- (id)initWithLoanType:(LoanType)loanType loanId:(NSString *)loanId flowId:(NSString *)flowId unitCode:(NSString *)unitCode navTitle:(NSString *)title webUrl:(NSString *)webUrl postRequestParameter:(NSString *)params completedBlock:(void(^)(BOOL result, id data))block;
/**
 拼接H5 URL
 
 @param dict 参数字典
 @param metaUrl 传入的baseUrl
 @return H5页面的完整URL
 */
- (NSString *)getCompleteH5UrlWithDictionary:(NSDictionary *)dict metaUrl:(NSString *)metaUrl;
    
@end



























