//
//  TPJSToNAExtension.h
//  HC_PromoteBusiness
//
//  Created by ztp on 16/10/26.
//  Copyright © 2016年 ztp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
/*
 * 用法说明：
 第一步：头文件调用TPJSToNAExtension.h 
 并且在应用WebView的控制器创建的时候创建TPJSToNAExtension对象
 @property (nonatomic,strong) TPJSToNAExtension *JNExtension;
 - (void)viewDidLoad {
      self.JNExtension = [[TPJSToNAExtension alloc]init];
 }
 第二步：在代理方法中创建JS环境
 - (void)webViewDidFinishLoad:(UIWebView *)webView
 {
    [self.JNExtension createJScontextWithWebView:_webView];
 }
 第三步：
 在webview的代理方法中添加
 - (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
 {
    if([self.JNExtension StartJStoNativeWithURLString:[[request URL] absoluteString]]){
       return NO;
    }
 };
  */

@interface TPJSToNAExtension : NSObject
@property (nonatomic,strong)JSContext *jsContext;   //创建的JS环境

@property (nonatomic,strong) NSString *shareTitle;  //分享的标题
@property (nonatomic,strong) NSString *shareContent;//分享的内容
@property (nonatomic,strong) NSString *shareImgUrl; //分享的图片地址URL
@property (nonatomic,strong) NSString *shareUrl;    //分享当前文章的URL
@property (nonatomic,strong) NSString *cityName;    //当前的位置城市


@property (nonatomic, copy) void (^accitionBlock)(NSDictionary *rawData, NSString *accitionstr, NSString *param);//回调方法
@property (nonatomic, copy) void (^shareBlock)(NSDictionary *shareDict);//回调方法
@property (nonatomic, copy) void (^smsBlock)(NSString *phoneNum, NSString *content);//短信回调方法

/*
 创建JS环境
 **/
- (void)createJScontextWithWebView:(UIWebView *)webview;
/*
 执行jscallback方法
 **/
- (void)runJSCallBackWithData:(NSString *)dataStr andMethod:(NSString *)method;
/*
 开始执行JS交互方法
 **/
- (BOOL)StartJStoNativeWithURLString:(NSString *)urlString;




@end
