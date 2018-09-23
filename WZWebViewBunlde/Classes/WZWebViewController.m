//
//  WZWebViewController.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/29.
//  Copyright © 2017年 cheyy. All rights reserved.
//·

#import "WZWebViewController.h"
#import <WebKit/WebKit.h>
#import <MessageUI/MessageUI.h>
#import "TPJSToNAExtension.h"
#import "NSURLRequest+NSURLRequestWithIgnoreSSL.h"
#import "MBProgressHUD+WZ.h"
#import "GlobalUnique.h"
#import <WZLogger/WZLogging.h>
#import "Masonry.h"
#import "WZCategory.h"
#import "WZMediator.h"

@interface WZWebViewController ()<WKNavigationDelegate, WKUIDelegate,MFMessageComposeViewControllerDelegate, UIWebViewDelegate>

@property (nonatomic, strong) MBProgressHUD *activityHUD;
@property (nonatomic, strong) CALayer *progressLayer;
@property (nonatomic, strong) UIBarButtonItem *backReturnBtn;
@property (nonatomic, strong) UIBarButtonItem *closeBtn;
@property (nonatomic, strong) TPJSToNAExtension *jNExtension;
@end

@implementation WZWebViewController

#pragma mark -- lifeCircle
- (id)initWithNavTitle:(NSString *)title webUrl:(NSString *)webUrl
{
    if (self = [super init]) {
        _navTitle = title;
        _webUrl = webUrl;
        _showBackBtn = YES;
        _goBackEnable = YES;
        _useUiWebView = NO;
    }
    return self;
}

- (id)initWithWebUrl:(NSString *)webUrl
{
    return [self initWithNavTitle:@"" webUrl:webUrl];
}

- (id)initWithNavTitle:(NSString *)title webUrl:(NSString *)webUrl postRequestParameter:(NSString *)params
{
    self = [self initWithNavTitle:title webUrl:webUrl];
    _parameter = params;
    return self;
}

- (id)initWithWebUrl:(NSString *)webUrl postRequestParameter:(NSString *)params
{
    return [self initWithNavTitle:@"" webUrl:webUrl postRequestParameter:params];
}

- (void)dealloc
{
    [self cleanTitleKVO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavBtns];
    [self layoutPageSubviews];
    [self loadH5Request];
//    [self registJsOcHander]; //JS交互事件
    [self configExtensionWithAction]; //url拦截的事件
    [self configNavTitle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self restoreNavBarColor];
}

-(void)configExtensionWithAction
{
    WS(ws)
    self.jNExtension.accitionBlock = ^(NSDictionary *rawData, NSString * accitionKey, NSString *param) {
        if ([accitionKey isEqualToString:@"my"]) {
            [ws goProfile];
        }else if ([accitionKey isEqualToString:@"exit"]) {
            [ws clickedLeftCloseItem:nil];
        } else if ([accitionKey isEqualToString:@"jumpapplogin"]) {
            [[CTMediator sharedInstance] WZMediator_PresentLoginRegFromController:ws animation:NO completion:^{
                [ws goServe];
            } withSucessBlock:nil];
        } else if ([accitionKey isEqualToString:@"tel"]) {
            [ws startDailTel:param];
        } else if ([accitionKey isEqualToString:@"gzTransPassModify"]) {
            if (ws.delegate && [ws.delegate respondsToSelector:@selector(modifyTransPassBlockResult:)]) {
                [ws.delegate modifyTransPassBlockResult:param];
            }
        } else if ([accitionKey isEqualToString:@"jsd"]) {
            if (ws.delegate && [ws.delegate respondsToSelector:@selector(pushJsdProductInfoAction:)]) {
                [ws.delegate pushJsdProductInfoAction:param];
            }
        } else if ([accitionKey isEqualToString:@"eventjsd"]) {
            if (ws.delegate && [ws.delegate respondsToSelector:@selector(pushJsdProductInfoAction:)]) {
                [ws.delegate pushJsdProductInfoAction:param];
            }
        } else if ([accitionKey isEqualToString:@"redPacket"]) {
            if (ws.delegate && [ws.delegate respondsToSelector:@selector(clickRegisterGetRedPacket:)]) {
                [ws.delegate clickRegisterGetRedPacket:param];
            }
        } else {
            WZLogDebug(@"receive param from H5！accitionKey is:%@ param is: %@ data is:%@", accitionKey, param, rawData);
            if ([ws conformsToProtocol:@protocol(HYDWebViewProtocol)]) {
                if ([(id<HYDWebViewProtocol>)ws dealH5Result:rawData] == NO) {
                    WZLogError(@"[%@]_无效协议: %@", [ws class], [rawData objectForKey:@"type"]);
                }
            }
        }
    };
    self.jNExtension.shareBlock = ^(NSDictionary *dict) {
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(shareWithFriendsAction:)]) {
            [ws.delegate shareWithFriendsAction:dict];
        }
    };
    self.jNExtension.smsBlock = ^(NSString *phoneNum, NSString *content) {
        MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
        vc.body = content;
        vc.recipients = @[phoneNum];
        vc.messageComposeDelegate = ws;
        [ws presentViewController:vc animated:YES completion:nil];
    };
}
    
#pragma mark -- event response

- (void)clickedLeftReturnItem:(UIBarButtonItem *)leftItem
{
    if (_goBackEnable) {
        if (_useUiWebView) {
            if ([self.webView canGoBack]) {
                [self.webView goBack];
            } else {
                if (_isClearCache) {
                    [self clearWebCache];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            if ([self.wkWebView canGoBack]) {
                [self.wkWebView goBack];
            } else {
                if (_isClearCache) {
                    [self clearWKWebCache];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } else {
        if (_useUiWebView) {
            if (_isClearCache) {
                [self clearWebCache];
            }
        } else {
            if (_isClearCache) {
                [self clearWKWebCache];
            }
        }
        if (_popRootEnable) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)clickedLeftCloseItem:(UIBarButtonItem *)leftItem
{
    if (_useUiWebView) {
        if (_isClearCache) {
            [self clearWebCache];
        }
    } else {
        if (_isClearCache) {
            [self clearWKWebCache];
        }
    }
    if (_popRootEnable) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)clickedRightItem
{
    if (_rightBtnType == WebShare) {
        [HYDShareHelper shareWithModel:self.shareModel];
    } else if (_rightBtnType == WebHelp) {
        [self startDailTel:kTelPhoneNum];
    }
}

- (void)startDailTel:(NSString *)tel
{
    NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"tel:%@",tel];
    UIWebView *callWebview = [[UIWebView alloc] init];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:str]];
    _useUiWebView ? [self.webView loadRequest:request]:[self.wkWebView loadRequest:request];
    [self.view addSubview:callWebview];
}

- (void)loadH5Request
{
    if ([self conformsToProtocol:@protocol(HYDWebViewProtocol)]) {
        WS(weakSelf);
        [(id<HYDWebViewProtocol>)self requestH5UrlWithComplete:^(BOOL succ, NSString *url) {
            if (succ) {
                weakSelf.webUrl = url;
                [weakSelf launchRequest];
            } else {
                WZLogError(@"%s get HYDWebViewProtocol URL is error, and the url is %@", [weakSelf class], url);
            }
        }];
    } else {
        [self launchRequest];
    }
}

-(void)launchRequest
{
    WZLogInfo(@"HYDWebView will load URL is:%@",self.webUrl);
    if (StringIsNullOrEmpty(self.webUrl)) {
        [MBProgressHUD showMessage:@"请求链接地址无效"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ([self.webUrl includeChinese]) {
        self.webUrl = [self.webUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15];
    if (StringIsNullOrEmpty(_parameter) == NO) {
        NSString *body = _parameter;
        [request setHTTPMethod: @"POST"];
        [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    }
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    _useUiWebView ? [self.webView loadRequest:request]:[self.wkWebView loadRequest:request];
}

- (void)registJsOcHander
{
    [self.jsBridge setWebViewDelegate:self];
    [self.jsBridge registerHandler:kSubmitFromWeb handler:^(id data, WVJBResponseCallback responseCallback) {
        WZLogInfo(@"submitFromWeb called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURL *URL = navigationAction.request.URL;
     NSString *scheme = [URL scheme];
     if([self.jNExtension StartJStoNativeWithURLString:[[navigationAction.request URL] absoluteString]]){
        decisionHandler(WKNavigationActionPolicyCancel);
     }else if ([[navigationAction.request.URL absoluteString] isEqualToString:@"wvjbscheme://__BRIDGE_LOADED__"] ||[[navigationAction.request.URL absoluteString] isEqualToString:@"https://__wvjb_queue_message__/"] ){
         
     } else if ([scheme isEqualToString:@"tel"]) {// 打电话
                    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                        [[UIApplication sharedApplication] openURL:URL];
                            // 一定要加上这句,否则会打开新页面
                        decisionHandler(WKNavigationActionPolicyCancel);
                        return;
                    }
     } else if ([URL.absoluteString containsString:@"sms"]) {// 发短信
             if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                 [[UIApplication sharedApplication] openURL:URL];
                 decisionHandler(WKNavigationActionPolicyCancel);
                 return;
             }
     } else if ([URL.absoluteString containsString:@"ituns.apple.com"]) {// 打开appstore
         if ([[UIApplication sharedApplication] canOpenURL:URL]) {
             [[UIApplication sharedApplication] openURL:URL];
             decisionHandler(WKNavigationActionPolicyCancel);
             return;
         }
     } else {
        NSURLResponse *response = nil;
        [NSURLConnection sendSynchronousRequest:navigationAction.request returningResponse:&response error:nil];
        if ([response isKindOfClass:NSHTTPURLResponse.class] && ((NSHTTPURLResponse *)response).statusCode == 404) {
            decisionHandler(WKNavigationActionPolicyAllow);
        }else{
            if (navigationAction.targetFrame == nil) {
                [webView loadRequest:navigationAction.request];
            }
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [MBProgressHUD showWithMessage:@"正在加载⋯"];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [MBProgressHUD hideHUD];
    [self hideFailView];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    [MBProgressHUD hideHUD];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    WZLogError(@"wkWebView request URL %@ failed and error is %@", self.webUrl, error);
    if (error.code == NSURLErrorCancelled) {//webview上一个请求没结束就开始下一个请求是会报-999
        return;
    }else{
        [MBProgressHUD hideHUD];
        WS(weakSelf);
        [self showFailViewWithType:LoadNetFail reFreshBlock:^{
            [weakSelf loadH5Request];
        }];
    }
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{

    
}
    
#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
        //  js 里面的alert实现，如果不实现，网页的alert函数无效  ,
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action){
                                                          completionHandler(NO);
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

#pragma mark -- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    if([self.jNExtension StartJStoNativeWithURLString:[[request URL] absoluteString]]){
        return NO;
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUD];
    [self hideFailView];
    [self.jNExtension createJScontextWithWebView:self.webView];
    if ((_useWebTitle || StringIsNullOrEmpty(self.navTitle))) {
        self.navigationItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    WZLogError(@"webView request URL %@ failed and error is %@", self.webUrl, error);
    [MBProgressHUD hideHUD];
    if (error.code == - 999) {//webview上一个请求没结束就开始下一个请求是会报-999
        return;
    }else{
        WS(weakSelf);
        [self showFailViewWithType:LoadNetFail reFreshBlock:^{
            [weakSelf loadH5Request];
        }];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showWithMessage:@"正在加载⋯"];
    [self hideFailView];
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- private methods
- (void)layoutPageSubviews
{
    [_useUiWebView ? self.webView:self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.mas_equalTo(self.view).mas_offset(64);
    }];
}

- (void)setupNavBtns
{
    if (_showCloseBtn && _showBackBtn) {
        [self.navigationItem setLeftBarButtonItems:@[self.backReturnBtn,self.closeBtn]];
    } else if (_showCloseBtn && !_showBackBtn) {
        [self.navigationItem setLeftBarButtonItems:@[self.closeBtn]];
    } else { // 其他情况：只显示返回按钮
        [self.navigationItem setLeftBarButtonItems:@[self.backReturnBtn]];
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(clickedRightItem) forControlEvents:UIControlEventTouchUpInside];
    btn.imageEdgeInsets  = UIEdgeInsetsMake(0, 0, 0, -10);
    btn.contentMode = UIViewContentModeCenter;
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"WZWebViewBunlde" ofType:@"bundle"]];
    if (_rightBtnType == WebShare && _shareModel != nil) {
        UIImage *image = [UIImage imageNamed:@"icon_share" inBundle:bundle compatibleWithTraitCollection:nil];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:image forState:UIControlStateHighlighted];
        btn.frame = CGRectMake(0, 0, btn.currentImage.size.width + 5, btn.currentImage.size.height + 5);
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    } else if (_rightBtnType == WebHelp) {
        UIImage *image = [UIImage imageNamed:@"icon_help_phone" inBundle:bundle compatibleWithTraitCollection:nil];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setImage:image forState:UIControlStateHighlighted];
        btn.frame = CGRectMake(0, 0, btn.currentImage.size.width + 5, btn.currentImage.size.height + 5);
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
}

- (void)stopWebLoading
{
    [MBProgressHUD hideHUD];
    _useUiWebView ? [self.webView stopLoading]:[self.wkWebView stopLoading];
}

// 根据传入的图片名，实现tintImage
- (UIImage *)tintImageWithImageName:(NSString *)imageName tintColor:(UIColor *)tintColor
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"WZWebViewBunlde" ofType:@"bundle"]];
    UIImage *originalImage = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, originalImage.size.width, originalImage.size.height);
    UIRectFill(bounds);
    [originalImage drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    UIImage *tintImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintImage;
}

#pragma mark - KVO

- (void)configNavTitle
{
    // 如果有运营配置的 title，一直显示此 title，否则使用 Web 页面的 title
    if (_useWebTitle || StringIsNullOrEmpty(self.navTitle)) {
        if (_useUiWebView) return;
        [self.wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        self.navigationItem.title = self.navTitle;
    }
    
    if (_useUiWebView == NO) {
        [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)cleanTitleKVO
{
    if (_useUiWebView || _wkWebView == nil) {
        return;
    }
    if (_useWebTitle || StringIsNullOrEmpty(self.navTitle)) {
        [self.wkWebView removeObserver:self forKeyPath:@"title"];
    }
    if (_useUiWebView == NO) {
        [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"title"]) {
        NSString *title = change[NSKeyValueChangeNewKey];
        if ([title isKindOfClass:[NSString class]]) {
            self.navigationItem.title = title;
        }
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressLayer.opacity = 1;
        if ([change[@"new"] floatValue] <[change[@"old"] floatValue]) {
            return;
        }
        self.progressLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH*[change[@"new"] floatValue], 3);
        if ([change[@"new"]floatValue] == 1.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressLayer.opacity = 0;
                self.progressLayer.frame = CGRectMake(0, 0, 0, 3);
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark -- getter & setter
- (WebViewJavascriptBridge *)jsBridge
{
    if (!_jsBridge) {
        _jsBridge = [WebViewJavascriptBridge bridgeForWebView:_useUiWebView?self.webView:self.wkWebView];
        [WebViewJavascriptBridge enableLogging];
    }
    return _jsBridge;
}

- (WKWebView *)wkWebView
{
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] init];
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        [self.view addSubview:_wkWebView];
    }
    return _wkWebView;
}

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (UIBarButtonItem *)backReturnBtn
{
    if (!_backReturnBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (CGColorEqualToColor(self.themeColor.CGColor, kwhiteColor.CGColor)) { // 主题色是白色
            UIImage *tintImage = [self tintImageWithImageName:@"return" tintColor:RGBA(51, 51, 51, 1)];
            [btn setImage:tintImage forState:UIControlStateNormal];
        } else {
            UIImage *tintImage = [self tintImageWithImageName:@"return" tintColor:kwhiteColor];
            [btn setImage:tintImage forState:UIControlStateNormal];
        }
        
        btn.imageEdgeInsets  = UIEdgeInsetsMake(0, -6, 0, 6);
        [btn addTarget:self action:@selector(clickedLeftReturnItem:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(0, 0, 30, 44);
        _backReturnBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
        _backReturnBtn.target = self;
    }
    return _backReturnBtn;
}

- (UIBarButtonItem *)closeBtn
{
    if (!_closeBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (CGColorEqualToColor(self.themeColor.CGColor, kwhiteColor.CGColor)) { // 主题色是白色
            UIImage *tintImage = [self tintImageWithImageName:@"icon_close" tintColor:RGBA(51, 51, 51, 1)];
            [btn setImage:tintImage forState:UIControlStateNormal];
        } else {
            UIImage *tintImage = [self tintImageWithImageName:@"icon_close" tintColor:kwhiteColor];
            [btn setImage:tintImage forState:UIControlStateNormal];
        }
        
        btn.imageEdgeInsets  = UIEdgeInsetsMake(0, -6, 0, 6);
        [btn addTarget:self action:@selector(clickedLeftCloseItem:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(0, 0, 30, 44);
        _closeBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    return _closeBtn;
}

- (TPJSToNAExtension *) jNExtension
{
    if (!_jNExtension) {
        _jNExtension = [[TPJSToNAExtension alloc] init];
    }
    return _jNExtension;
}

- (CALayer *)progressLayer
{
    if (!_progressLayer) {
        UIView *progress = [[UIView alloc] init];
        progress.frame = CGRectMake(0, 0, SCREEN_WIDTH, 3);
        progress.backgroundColor = [UIColor  clearColor];
        [self.wkWebView addSubview:progress];
        _progressLayer = [CALayer layer];
        _progressLayer.frame = CGRectMake(0, 0, 0, 3);
        _progressLayer.backgroundColor = [UIColor greenColor].CGColor;
        [progress.layer addSublayer:_progressLayer];
    }
    return _progressLayer;
}

- (void)clearWKWebCache
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        NSSet *websiteDataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache,
                                                        WKWebsiteDataTypeMemoryCache,
                                                        WKWebsiteDataTypeCookies]];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
        }];
    } else {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }
}

- (void)clearWebCache
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}
@end
