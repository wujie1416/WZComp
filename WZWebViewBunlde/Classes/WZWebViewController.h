//
//  WZWebViewController.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/29.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "HYDViewController.h"
#import "HYDShareHelper.h"
#import "WebViewJavascriptBridge.h"

#define  kSubmitFromNative      @"submitFromNative"
#define  kSubmitFromWeb         @"submitFromWeb"

/**
 参考：https://github.com/marcuswestin/WebViewJavascriptBridge
 
 简单说明（JS）：
 1、Copy and paste setupWebViewJavascriptBridge into your JS:
 
     function setupWebViewJavascriptBridge(callback) {
        if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
        if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
        window.WVJBCallbacks = [callback];
        var WVJBIframe = document.createElement('iframe');
        WVJBIframe.style.display = 'none';
        WVJBIframe.src = 'https://__bridge_loaded__';
        document.documentElement.appendChild(WVJBIframe);
        setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
     }
 
     setupWebViewJavascriptBridge(function(bridge) {
        
        //1.1 注册OC调用JS的响应函数
        bridge.registerHandler('submitFromNative', function(data, responseCallback) {
            console.log("JS Echo called with:", data)
            responseCallback(data)
        })
 
        //1.2 JS调用OC的方法
        bridge.callHandler('submitFromWeb', {'share':'value'}, function responseCallback(responseData) {
            console.log("JS received response:", responseData)
        })
    })
 
 
 简单说明（OC）：
        //2.1 注册JS调用OC的响应方法
         [self.jsBridge registerHandler:submitFromWeb handler:^(id data, WVJBResponseCallback responseCallback) {
             WZLogInfo(@"submitFromWeb called: %@", data);
             responseCallback(@"Response from testObjcCallback");
         }];
        //2.2 OC调用JS的方法
        [self.jsBridge callHandler:submitFromNative data:@{ @"foo":@"before ready" }];
 
 */


@protocol WZWebViewControllerDelegate <NSObject>
@optional
- (void)modifyTransPassBlockResult:(NSString *)result;  //密码管理-修改交易密码 结果
- (void)pushJsdProductInfoAction:(NSString *)result;    //进入极速贷组件
- (void)shareWithFriendsAction:(NSDictionary *)aDict;   //分享事件
- (void)clickRegisterGetRedPacket:(NSString *)result;   //点击按钮“注册领红包”
@end


@protocol HYDWebViewProtocol <NSObject>

/**
 获取h5页面url
 
 @param block 回调方法
 */
- (void)requestH5UrlWithComplete:(void(^)(BOOL succ, NSString *url))block;

/**
 初始化方法——无需flowId
 
 @param rawData h5传回的数据，包含type和data
 @return 是否能处理该type协议
 */
- (BOOL)dealH5Result:(NSDictionary *)rawData;
@end


typedef NS_ENUM(NSUInteger, WebRightBtnType) {
    WebNone,       //默认没有右侧按钮
    WebShare,      //分享按钮
    WebHelp,       //电话帮助按钮
};

@interface WZWebViewController : HYDViewController

/**
    回调方法的delegate
 */
@property(nonatomic, weak) id<WZWebViewControllerDelegate> delegate;
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WebViewJavascriptBridge *jsBridge;

/**
 http请求中的body参数
 */
@property (nonatomic, copy) NSString *parameter;
/**
 设置的原生导航栏标题
 */
@property (nonatomic ,copy) NSString *navTitle;

/**
 请求的url地址
 */
@property (nonatomic ,copy) NSString *webUrl;

/**
 是否使用UIWebview进行访问，默认为NO
 */
@property(nonatomic, assign) BOOL useUiWebView;

/**
 是否使用网页的 document.title 作为导航栏的title
 */
@property(nonatomic, assign) BOOL useWebTitle;

/**
 导航栏显示返回按钮外，是否显示“关闭”按钮
 */
@property(nonatomic, assign) BOOL showCloseBtn;

/**
 导航栏是否显示“返回”按钮
 */
@property(nonatomic, assign) BOOL showBackBtn;

/**
 点击返回按钮时，调用webView的goback，默认为YES
 */
@property(nonatomic, assign) BOOL goBackEnable;

/**
 点击返回按钮时，pop到rootViewController,默认为NO
 */
@property(nonatomic, assign) BOOL popRootEnable;

/**
 设置导航栏右侧按钮的类型：分享or帮助,默认没有右侧按钮
 */
@property(nonatomic, assign) WebRightBtnType rightBtnType;

/**
 分享的model
 */
@property(nonatomic, strong) HYDShareModel *shareModel;

/**
 是否清楚缓存
 */
@property(nonatomic, assign) BOOL isClearCache;

/**
 初始化webViewController

 @param title 导航栏标题
 @param webUrl 请求的链接地址
 @return 示例
 */
- (id)initWithNavTitle:(NSString *)title webUrl:(NSString *)webUrl;

/**
 初始化webViewController
 
 @param webUrl 请求的链接地址
 @return 示例
 */
- (id)initWithWebUrl:(NSString *)webUrl;

/**
 初始化webViewController

 @param title 导航栏标题
 @param webUrl 请求的链接地址
 @param params 请求参数
 @return 示例
 */
- (id)initWithNavTitle:(NSString *)title webUrl:(NSString *)webUrl postRequestParameter:(NSString *)params;

/**
 初始化webViewController
 
 @param webUrl 请求的链接地址
 @param params 请求参数
 @return 示例
 */
- (id)initWithWebUrl:(NSString *)webUrl postRequestParameter:(NSString *)params;

/**
   返回事件
*/
- (void)clickedLeftReturnItem:(UIBarButtonItem *)leftItem;
    
/**
   关闭页面  
*/
- (void)clickedLeftCloseItem:(UIBarButtonItem *)leftItem;

/**
     停止加载
 */
- (void)stopWebLoading;

@end



























