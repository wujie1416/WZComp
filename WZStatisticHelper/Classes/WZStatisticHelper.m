//
//  WZStatisticHelper.m
//  HC-HYD
//
//  Created by 老司机车 on 20/11/2017.
//  Copyright © 2017 cheyy. All rights reserved.
//

#import "WZStatisticHelper.h"
#import "UMMobClick/MobClick.h"
#import "HYDLSUserManager.h"
#import "HYDNetWork.h"
#import <WZLocationHelper/WZLocationHelper.h>
#import "WZReachability.h"
#include <sys/sysctl.h>

typedef NS_ENUM(NSUInteger, BigDataLogType) {
    BigDataLogTypeClick,
    BigDataLogTypePv,
    BigDataLogTypeSt,
};

typedef NS_ENUM(NSUInteger, HYDLogType) {
    HYDLogTypeClick,
    HYDLogTypePv,
};


NSString *const kWzStatisticLogIdentifier = @"<---------------> user";
NSString *kWzCurrentFlowType = @"LA-3-003-00011";


static inline NSString *getCurrentTimeMillis()
{
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];
    NSString *curTime = [NSString stringWithFormat:@"%llu",theTime];
    return curTime;
}

//解除URL中Escape编码
static inline NSString *decodeFromPercentEscapeString(NSString *input)
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0,
                                                      [outputStr length])];
    return  [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

//json转Dict
static inline NSDictionary *dictionaryWithJsonString(NSString *jsonString)
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        return nil;
    }
    return dic;
}

@implementation UIView (Statistics)
static const char *UIView_wzTagIdentifer = "UIView_wzTagIdentifer";
- (NSString *)wzTag{
    return objc_getAssociatedObject(self, UIView_wzTagIdentifer);
}
- (void)setWzTag:(NSString *)wzTag{
    objc_setAssociatedObject(self, UIView_wzTagIdentifer, wzTag, OBJC_ASSOCIATION_COPY);
}

+ (void)load
{
    Method systemMethod = class_getInstanceMethod(self, @selector(addGestureRecognizer:));
    Method myMethod = class_getInstanceMethod(self, @selector(hyd_addGestureRecognizer:));
    method_exchangeImplementations(systemMethod, myMethod);
}

- (void)hyd_addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        [gestureRecognizer addTarget:self action:@selector(hyd_onTapGestureBuryPoint:)];
    }
    [self hyd_addGestureRecognizer:gestureRecognizer];
}

- (void)hyd_onTapGestureBuryPoint:(UIGestureRecognizer *)sender
{
    UIView *view = [(UIGestureRecognizer *)sender view];
    [WZStatisticHelper recordWithWzTag:view.wzTag fromSender:view action:NSSelectorFromString(@"OnClickBtn") to:nil];
}

@end

@implementation UITableView (Statistics)

+ (void)load
{
    //获取着两个方法
    Method systemMethod = class_getInstanceMethod(self, @selector(setDelegate:));
    Method myMethod = class_getInstanceMethod(self, @selector(hyd_setDelegate:));
    method_exchangeImplementations(systemMethod, myMethod);
}

- (void)hyd_setDelegate:(id<UITableViewDelegate>)delegate
{
    [self hyd_setDelegate:delegate];
    Class class = [delegate class];
    SEL originalSelector = @selector(tableView:didSelectRowAtIndexPath:);
    if (![delegate respondsToSelector:originalSelector]) {
        return;
    }
    SEL swizzledSelector = NSSelectorFromString(@"hyd_didSelectRowAtIndexPath");
    class_addMethod(class, originalSelector, (IMP)class_getMethodImplementation(class, originalSelector), "v@:@@");
    if (class_addMethod(class, swizzledSelector, (IMP)hyd_didSelectRowAtIndexPath, "v@:@@")) {
        Method dis_originalMethod = class_getInstanceMethod(class, swizzledSelector);
        Method dis_swizzledMethod = class_getInstanceMethod(class, originalSelector);
        method_exchangeImplementations(dis_originalMethod, dis_swizzledMethod);
    }
}

void hyd_didSelectRowAtIndexPath(id self, SEL _cmd, id tableView, id indexpath)
{
    NSString *contentPage = NSStringFromClass([self class]);
    if ([self isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)self;
        NSString *title = vc.navigationItem.title?:vc.title;
        contentPage = title?:NSStringFromClass([vc class]);
    }
    SEL selector = NSSelectorFromString(@"hyd_didSelectRowAtIndexPath");
    ((void(*)(id, SEL,id, id))objc_msgSend)(self, selector, tableView, indexpath);
    NSString *cellId = [NSString stringWithFormat:@"cell_%ld_%ld", (long)((NSIndexPath *)indexpath).section, (long)((NSIndexPath *)indexpath).row];
    NSDictionary *dict = @{@"name":cellId, @"type":@"button",@"activate_time":getCurrentTimeMillis(),@"finish_time":getCurrentTimeMillis(),@"page_name":contentPage?:@""};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *yyJsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WZLogInfo(@"%@ clicked tableView's cell (%ld Section %ld Row) on %@ page^&^%@", kWzStatisticLogIdentifier, ((NSIndexPath *)indexpath).section,((NSIndexPath *)indexpath).row, contentPage, yyJsonStr);
    [WZStatisticHelper recordWithWzTag:cellId fromSender:self action:NSSelectorFromString(@"OnClickCell:") to:tableView];
}

@end

@implementation UICollectionView (Statistics)

+ (void)load
{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(setDelegate:)), class_getInstanceMethod(self, @selector(hyd_setDelegate:)));
}

- (void)hyd_setDelegate:(id<UICollectionViewDelegate>)delegate
{
    [self hyd_setDelegate:delegate];
    Class class = [delegate class];
    SEL originalSelector = @selector(collectionView:didSelectItemAtIndexPath:);
    if (![delegate respondsToSelector:originalSelector]) {
        return;
    }
    SEL swizzledSelector = NSSelectorFromString(@"hyd_didSelectItemAtIndexPath");
    class_addMethod(class, originalSelector, (IMP)class_getMethodImplementation(class, originalSelector), "v@:@@");
    if (class_addMethod(class, swizzledSelector, (IMP)hyd_didSelectItemAtIndexPath, "v@:@@")) {
        Method dis_originalMethod = class_getInstanceMethod(class, swizzledSelector);
        Method dis_swizzledMethod = class_getInstanceMethod(class, originalSelector);
        method_exchangeImplementations(dis_originalMethod, dis_swizzledMethod);
    }
}

void hyd_didSelectItemAtIndexPath(id self, SEL _cmd, id collectionView, id indexpath)
{
    NSString *contentPage = NSStringFromClass([self class]);
    if ([self isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)self;
        NSString *title = vc.navigationItem.title?:vc.title;
        contentPage = title?:[NSString stringWithUTF8String:class_getName([vc class])];
    }
    
    SEL selector = NSSelectorFromString(@"hyd_didSelectItemAtIndexPath");
    ((void(*)(id, SEL,id, id))objc_msgSend)(self, selector, collectionView, indexpath);
    NSString *cellId = [NSString stringWithFormat:@"cell_%ld_%ld", (long)((NSIndexPath *)indexpath).section, (long)((NSIndexPath *)indexpath).row];
    NSDictionary *dict = @{@"name":cellId, @"type":@"button",@"activate_time":getCurrentTimeMillis(),@"finish_time":getCurrentTimeMillis(),@"page_name":contentPage?:@""};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *yyJsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WZLogInfo(@"%@ clicked tableView's cell (%ld Section %ld Row) on %@ page^&^%@",kWzStatisticLogIdentifier, ((NSIndexPath *)indexpath).section,((NSIndexPath *)indexpath).row, contentPage, yyJsonStr);
    [WZStatisticHelper recordWithWzTag:cellId fromSender:self action:NSSelectorFromString(@"OnClickCell:") to:collectionView];
}

@end

@implementation WKWebView (Statistic)

+(void)load
{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(setNavigationDelegate:)), class_getInstanceMethod(self, @selector(hyd_setNavigationDelegate:)));
}

- (BOOL)hasMethod:(NSString *)methodName inClass:(Class) class
{
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(class, &methodCount);
    for (int i = 0; i < methodCount; i++) {
        Method temp = methodList[i];
        SEL name_F = method_getName(temp);
        if ([NSStringFromSelector(name_F) isEqualToString:methodName]) {
            return YES;
        }
    }
    free(methodList);
    return NO;
}

+ (Class)findWebViewClassInheriChain:(Class)class
{
    NSString *className = NSStringFromClass(class);
    if ([className isEqualToString:@"WZWebViewController"] || [className isEqualToString:@"NSObject"]) {
        return class;
    } else {
        return [self findWebViewClassInheriChain:[class superclass]];
    }
}

- (void)hyd_setNavigationDelegate:(id<WKNavigationDelegate>)delegate
{
    [self hyd_setNavigationDelegate:delegate];
    Class class = [[self class] findWebViewClassInheriChain:[delegate class]];
    if (![NSStringFromClass(class) isEqualToString:@"WZWebViewController"]) {
        return;
    }
    /**
        当基类中存在decidePolicyForNavigationAction这个方法，而子类中并不存在，那么在第一个子类进行hook时，会将hyd_decidePolicyForNavigationAction和基类的方法实现进行交换
        那么当第二个子类被创建出来进行hook时，那么会将hyd_decidePolicyForNavigationAction跟基类的hyd_decidePolicyForNavigationAction进行交换，此时存在两个hyd_decidePolicyForNavigationAction
        循环调用导致的死循环（虽然地址不同，但是实现一致的死循环）。
        解决方法：
        1、在进行方法交换前，对当前类进行判断，是否当前类中存在该方法，如果不存在则去基类中寻找，直到找到存在该方法的基类，然后将hyd_decidePolicyForNavigationAction添加到该类上面，这样当
           第一个子类销毁掉，父类中依旧存在两个方法，第二个子类出现时，则不会在进行方法的添加和交换了。
           ps：寻找具备该方法的父类：if (![self hasMethod:@"webView:decidePolicyForNavigationAction:decisionHandler" inClass:class]) class = [class superclass];
        2、不论该类中待交换的方法存在与否，在交换之前，都将系统方法在该类中添加一遍，这样在进行方法交换时则是实实在在的对子类的方法进行hook，每一个子类的销毁与创建不在互相影响。
           ps：现在工程中采用该解决方案
     */

    SEL originalSelector = @selector(webView:decidePolicyForNavigationAction:decisionHandler:);
    if (![delegate respondsToSelector:originalSelector]) {
        return;
    }
    SEL swizzledSelector = NSSelectorFromString(@"hyd_decidePolicyForNavigationAction");
    class_addMethod(class, originalSelector, (IMP)class_getMethodImplementation(class, originalSelector), "v@:@@@");
    if (class_addMethod(class, swizzledSelector, (IMP)hyd_decidePolicyForNavigationAction, "v@:@@@")) {
        Method dis_originalMethod = class_getInstanceMethod(class, swizzledSelector);
        Method dis_swizzledMethod = class_getInstanceMethod(class, originalSelector);
        method_exchangeImplementations(dis_originalMethod, dis_swizzledMethod);
    }
}

void hyd_decidePolicyForNavigationAction(id self, SEL _cmd, id webView, id navigationAction, id decisionHandler)
{
    typedef void(^decisionBlock) (WKNavigationActionPolicy type);
    decisionBlock block = decisionHandler;
    NSString *loadUrl = [[[(WKNavigationAction *)navigationAction request] URL] absoluteString];
     if([loadUrl rangeOfString:@"hengchang://puhui.com/?"].location != NSNotFound && ![self isKindOfClass:NSClassFromString(@"WKWebViewJavascriptBridge")]){
        loadUrl = [loadUrl stringByReplacingOccurrencesOfString:@"hengchang://puhui.com/?hc_parms=" withString:@""];
        loadUrl = decodeFromPercentEscapeString(loadUrl);
        NSDictionary * dict = dictionaryWithJsonString(loadUrl);
        /*
         HCBridge.Request('burryPointLoad', data)
         data = {
             pageCode: '', // 当前页面id
             sourceCode: '', // 上个页面的id 只有h5跳转h5时才会穿
         }
         第二个函数：页面中的点击事件调用
         HCBridge.Request('burryPointClick', data)
         data = {
             pageCode: '', // 当前页面id
             sourceCode: '', // 上个页面的id 只有h5跳转h5时才会传
             clickId: '', // 点击的元素id
         }
         */
        NSDictionary *data = [dict objectForKey:@"data"];
        NSString *pageCode = data[@"pageCode"];
        if (![pageCode isKindOfClass:[NSString class]] || pageCode.length <= 0) {
            pageCode = UIViewController.wzCurPagePageCode;
        }
        UIViewController.wzCurPagePageCode = pageCode;
        NSString *sourceCode = data[@"sourceCode"];
        if (![sourceCode isKindOfClass:[NSString class]] || sourceCode.length <= 0) {
            sourceCode = UIViewController.wzLastBuriedPageCode;
        }
        UIViewController.wzLastBuriedPageCode = sourceCode;
        if ([[dict objectForKey:@"type"] isEqualToString:@"burryPointLoad"]) {
            [WZStatisticHelper reportPvBuryData];
            block(WKNavigationActionPolicyCancel);
            WZLogInfo(@"webView receive h5 buryPoint msg:%@", dict);
            return;
        } else if ([[dict objectForKey:@"type"] isEqualToString:@"burryPointClick"]) {
            [WZStatisticHelper recordWithWzTag:data[@"clickId"]?:@"Nan" fromSender:[UIButton new] action:NSSelectorFromString(@"OnClickBtn") to:nil];
            block(WKNavigationActionPolicyCancel);
            WZLogInfo(@"webView receive h5 buryPoint msg:%@", dict);
            return;
        }
    }
    SEL selector = NSSelectorFromString(@"hyd_decidePolicyForNavigationAction");
    ((void(*)(id, SEL, id, id, id))objc_msgSend)(self, selector, webView, navigationAction, decisionHandler);
}

@end

@implementation UIWebView (Statistic)

+(void)load
{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(setDelegate:)), class_getInstanceMethod(self, @selector(hyd_setDelegate:)));
}

- (void)hyd_setDelegate:(id<UIWebViewDelegate>)delegate
{
    [self hyd_setDelegate:delegate];
    Class class = [WKWebView findWebViewClassInheriChain:[delegate class]];
    if (![NSStringFromClass(class) isEqualToString:@"WZWebViewController"]) {
        return;
    }
    
    SEL originalSelector = @selector(webView:shouldStartLoadWithRequest:navigationType:);
    if (![delegate respondsToSelector:originalSelector]) {
        return;
    }
    class_addMethod(class, originalSelector, (IMP)class_getMethodImplementation(class, originalSelector), "B@:@@@");
    if (class_addMethod(class, NSSelectorFromString(@"hyd_shouldStartLoadWithRequest"), (IMP)hyd_shouldStartLoadWithRequest, "B@:@@@")) {
        Method dis_originalMethod = class_getInstanceMethod(class, NSSelectorFromString(@"hyd_shouldStartLoadWithRequest"));
        Method dis_swizzledMethod = class_getInstanceMethod(class, originalSelector);
        method_exchangeImplementations(dis_originalMethod, dis_swizzledMethod);
    }
}

bool hyd_shouldStartLoadWithRequest(id self, SEL _cmd, id webView, id request, UIWebViewNavigationType navigationType)
{
    NSString *loadUrl = [[request URL] absoluteString];
     if([loadUrl rangeOfString:@"hengchang://puhui.com/?"].location != NSNotFound && ![self isKindOfClass:NSClassFromString(@"WKWebViewJavascriptBridge")]){
        loadUrl = [loadUrl stringByReplacingOccurrencesOfString:@"hengchang://puhui.com/?hc_parms=" withString:@""];
        loadUrl = decodeFromPercentEscapeString(loadUrl);
        NSDictionary * dict = dictionaryWithJsonString(loadUrl);
        NSDictionary *data = [dict objectForKey:@"data"];
        NSString *pageCode = data[@"pageCode"];
        if (![pageCode isKindOfClass:[NSString class]] || pageCode.length <= 0) {
            pageCode = UIViewController.wzCurPagePageCode;
        }
        UIViewController.wzCurPagePageCode = pageCode;
        NSString *sourceCode = data[@"sourceCode"];
        if (![sourceCode isKindOfClass:[NSString class]] || sourceCode.length <= 0) {
            sourceCode = UIViewController.wzLastBuriedPageCode;
        }
        UIViewController.wzLastBuriedPageCode = sourceCode;
        if ([[dict objectForKey:@"type"] isEqualToString:@"burryPointLoad"]) {
            [WZStatisticHelper reportPvBuryData];
            WZLogInfo(@"webView receive h5 buryPoint msg:%@", dict);
            return NO;
        } else if ([[dict objectForKey:@"type"] isEqualToString:@"burryPointClick"]) {
            [WZStatisticHelper recordWithWzTag:data[@"clickId"]?:@"Nan" fromSender:[UIButton new] action:NSSelectorFromString(@"OnClickBtn") to:nil];
            WZLogInfo(@"webView receive h5 buryPoint msg:%@", dict);
            return NO;
        }
    }
    
    SEL selector = NSSelectorFromString(@"hyd_shouldStartLoadWithRequest");
    return ((bool (*)(id, SEL, id, id, UIWebViewNavigationType))objc_msgSend)(self, selector, webView, request, navigationType);

}


@end

@interface UIControl()
@property (nonatomic, assign) NSTimeInterval hyd_acceptEventTime;
@end
@implementation UIControl (Statistics)

static const char *UIControl_acceptEventInterval = "UIControl_acceptEventInterval";
static const char *UIControl_acceptEventTime = "UIControl_acceptEventTime";

- (NSTimeInterval )hyd_acceptEventInterval{
    return [objc_getAssociatedObject(self, UIControl_acceptEventInterval) doubleValue];
}
- (NSTimeInterval )hyd_acceptEventTime{
    return [objc_getAssociatedObject(self, UIControl_acceptEventTime) doubleValue];
}

- (void)setHyd_acceptEventInterval:(NSTimeInterval)hyd_acceptEventInterval{
    objc_setAssociatedObject(self, UIControl_acceptEventInterval, @(hyd_acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)setHyd_acceptEventTime:(NSTimeInterval)hyd_acceptEventTime{
    objc_setAssociatedObject(self, UIControl_acceptEventTime, @(hyd_acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load
{
    Method systemMethod = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    SEL sysSEL = @selector(sendAction:to:forEvent:);
    Method myMethod = class_getInstanceMethod(self, @selector(hyd_sendAction:to:forEvent:));
    SEL mySEL = @selector(hyd_sendAction:to:forEvent:);

    BOOL didAddMethod = class_addMethod(self, sysSEL, method_getImplementation(myMethod), method_getTypeEncoding(myMethod));
    if (didAddMethod) {
        class_replaceMethod(self, mySEL, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        method_exchangeImplementations(systemMethod, myMethod);
    }
}

- (void)hyd_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    UIViewController *superViewController = nil;
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            superViewController = (UIViewController *)nextResponder;
            break;
        }
    }
    
    if ([target isKindOfClass:NSClassFromString(@"HYDViewController")] && ![superViewController isKindOfClass:NSClassFromString(@"HYDViewController")]) {
        superViewController = target;
    }
    NSString *title = superViewController.navigationItem.title?:superViewController.title;
    NSString *contentPage = title?:(NSStringFromClass(superViewController.class)?:NSStringFromClass(self.superview.class));
    
    if ([self isKindOfClass:[UIButton class]]) {
        if (NSDate.date.timeIntervalSince1970 - self.hyd_acceptEventTime < self.hyd_acceptEventInterval) {
            self.hyd_acceptEventTime = NSDate.date.timeIntervalSince1970;
            return;
        }
        if (self.hyd_acceptEventInterval > 0) {
            self.hyd_acceptEventTime = NSDate.date.timeIntervalSince1970;
        }
        UIButton *btn = (UIButton *)self;
        NSString *btnName = btn.currentTitle?:[NSString stringWithFormat:@"%@_%@",NSStringFromClass([btn class]), NSStringFromSelector(action)];
        NSDictionary *dict = @{@"name":btnName, @"type":@"button",@"activate_time":getCurrentTimeMillis(),@"finish_time":getCurrentTimeMillis(),@"page_name":contentPage};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        NSString *yyJsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        WZLogInfo(@"%@ clicked %@ button with %@ action on the %@ Page (---self is: %@  target is: %@---)^&^%@",kWzStatisticLogIdentifier, btnName, NSStringFromSelector(action), contentPage, self, target, yyJsonStr);
    } else if ([self isKindOfClass:[UITextField class]] || [self isKindOfClass:[UITextView class]]) {
        UITextField *tf = (UITextField *)self;
        NSString *tfName = tf.placeholder?:[NSString stringWithFormat:@"%@_%@",NSStringFromClass([tf class]), NSStringFromSelector(action)];
        NSDictionary *dict = @{@"name":tfName, @"type":@"text", @"activate_time":getCurrentTimeMillis(),@"value":tf.text,@"page_name":contentPage};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        NSString *yyJsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        WZLogInfo(@"%@ operate %@ UITextField with %@ action (current text is %@) on the %@ Page (---self is: %@  target is: %@---)^&^%@",kWzStatisticLogIdentifier, tfName, NSStringFromSelector(action), tf.text,contentPage,self, target, yyJsonStr);
    } else if ([self isKindOfClass:[UISwitch class]]) {
        UISwitch *sw = (UISwitch *)self;
        WZLogInfo(@"%@ operate %@ UISwitch with %@ action (On is %@) on the %@ Page (---self is: %@  target is: %@---)",kWzStatisticLogIdentifier, NSStringFromClass(sw.class), NSStringFromSelector(action), sw.isOn,contentPage,self, target);
    }
    
    [WZStatisticHelper recordWithWzTag:self.wzTag fromSender:self action:(SEL)action to:target];
    [self hyd_sendAction:action to:target forEvent:event];
}

@end

static NSString *_wzLastBuriedPageCode = @"";
static NSString *_wzPageEnterTime = @"";
static NSString *_wzCurPagePageCode = @"";
static NSMutableArray *_wzBuriedEventDataBase = nil;
@implementation UIViewController(Statistics)
+ (void)load
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        swizzInstance([self class],@selector(viewWillAppear:),@selector(swiz_viewWillAppear:));
        swizzInstance([self class],@selector(viewWillDisappear:),@selector(swiz_viewWillDisAppear:));
        UIViewController.wzBuriedEventDataBase = [NSMutableArray new];
    });
}

+ (void)setWzLastBuriedPageCode:(NSString *)wzLastBuriedPageCode{
    _wzLastBuriedPageCode = wzLastBuriedPageCode;
}
+ (void)setWzCurPagePageCode:(NSString *)wzCurPagePageCode{
    _wzCurPagePageCode = wzCurPagePageCode;
}
+ (void)setWzPageEnterTime:(NSString *)wzPageEnterTime{
    _wzPageEnterTime = wzPageEnterTime;
}
+ (void)setWzBuriedEventDataBase:(NSMutableArray *)wzBuriedEventDataBase{
    _wzBuriedEventDataBase = wzBuriedEventDataBase;
}
+ (NSString *)wzLastBuriedPageCode{
    return _wzLastBuriedPageCode?:@"";
}
+ (NSString *)wzCurPagePageCode{
    return _wzCurPagePageCode?:@"";
}
+ (NSString *)wzPageEnterTime{
    return _wzPageEnterTime;
}
+ (NSMutableArray *)wzBuriedEventDataBase{
    return _wzBuriedEventDataBase;
}

- (void)swiz_viewWillAppear:(BOOL)animated
{
    if (!([self isKindOfClass:NSClassFromString(@"HYDViewController")] || [self isKindOfClass:NSClassFromString(@"HYDTableViewController")]) ||
         [NSStringFromClass([self class]) isEqualToString:@"HYDLoginViewController"]) {
        [self swiz_viewWillAppear:animated];
        return;
    }
    UIViewController.wzPageEnterTime = [NSString stringWithFormat:@"%@", getCurrentTimeMillis()];
    UIViewController.wzCurPagePageCode = [NSString stringWithFormat:@"%@", [self class]];
    [WZStatisticHelper didEnterPageVc:self];
    [self swiz_viewWillAppear:animated];
}


- (void)swiz_viewWillDisAppear:(BOOL)animated
{
    if (!([self isKindOfClass:NSClassFromString(@"HYDViewController")] || [self isKindOfClass:NSClassFromString(@"HYDTableViewController")]) ||
        [NSStringFromClass([self class]) isEqualToString:@"HYDLoginViewController"]) {
        [self swiz_viewWillDisAppear:animated];
        return;
    }
    [WZStatisticHelper didLeavePageVc:self];
    
    UIViewController.wzLastBuriedPageCode = [NSString stringWithFormat:@"%@", [self class]];
    [self swiz_viewWillDisAppear:animated];
}

/*
    仅限本类方法，不适用delegate的方法
 */
void swizzInstance(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (!originalMethod || !swizzledMethod) {
        WZLogError(@"swizzle originSelector<%@> & swizzledSelector<%@> In class<%@> failed!", NSStringFromSelector(originalSelector), NSStringFromSelector(swizzledSelector), class);
        return;
    }
    BOOL didAddMethod =
    class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod),method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end


@implementation WZStatisticHelper

+ (void)load
{
    NSString *initMsg = [NSString stringWithFormat:@"app(%@) start and init buryPoint lib !", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]];
    WZLogInfo(@"%@", initMsg);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UMConfigInstance.appKey = @"5811ab7ca40fa3498f0039f4";
        UMConfigInstance.ePolicy = SEND_INTERVAL;
        [MobClick setLogSendInterval:90];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [MobClick setAppVersion:version];
        [MobClick setCrashReportEnabled:NO];
        [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！
        
        CGRect rect_screen = [[UIScreen mainScreen]bounds];
        CGFloat scale_screen = [UIScreen mainScreen].scale;
        CGFloat width = rect_screen.size.width*scale_screen;
        CGFloat height = rect_screen.size.height*scale_screen;
        [WZStatisticHelper report2BigDataWithType:BigDataLogTypeSt data:@{@"os":@"iOS",
                                                             @"ov":[UIDevice currentDevice].systemVersion,
                                                             @"br":@"apple",
                                                             @"bs":[WZStatisticHelper machineModelName],
                                                             @"ul":@"utf-8",
                                                             @"ps":[NSString stringWithFormat:@"%ldx%ld",(long)rect_screen.size.width, (long)rect_screen.size.height],
                                                             @"sr":[NSString stringWithFormat:@"%ldx%ld",(long)width, (long)height],
                                                             @"sc":@"24-bit"
                                                             }];
    });
}

+ (void)didEnterPageVc:(UIViewController *)page
{
    [self setWzCurrentFlowTypeWithPageVC:page];
    
    if ([[WZLocationHelper sharedLocation] isEnabledLocation] &&
        [WZLocationHelper sharedLocation].latitude == 0) {
        [[WZLocationHelper sharedLocation] startRequestLocationAndReport];
    }
    NSString *title = page.navigationItem.title?:page.title;
    NSDictionary *dict = @{@"enter_time":getCurrentTimeMillis(), @"page_name":title?:NSStringFromClass([page class])};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *yyJsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WZLogInfo(@"%@ enter %@<%@> page^&^%@",kWzStatisticLogIdentifier, title, NSStringFromClass([page class]),yyJsonStr);
    [WZStatisticHelper reportPvBuryData];
}

+ (void)reportPvBuryData
{
    [self report2BigDataWithType:BigDataLogTypePv data:@{@"jd":[[WZLocationHelper sharedLocation] isEnabledLocation]?@([WZLocationHelper sharedLocation].latitude):@0,
                                                         @"wd":[[WZLocationHelper sharedLocation] isEnabledLocation]?@([WZLocationHelper sharedLocation].longitude):@0,
                                                         @"icrt":getCurrentTimeMillis(),
                                                         @"nt":([WZReachability reachability].status == WZReachabilityStatusWiFi)?@"wifi":([WZReachability reachability].wwanStatus == WZReachabilityWWANStatus4G)?@"4G":@"3G"
                                                         }];
    
    [self reportWithData:@{@"phone_model":[WZStatisticHelper machineModelName],
                           @"os_type":@"iOS",
                           @"uuid":HYDUserModelManagerShared.userModel.userId,
                           @"phone_num":HYDUserModelManagerShared.userModel.userPhone,
                           @"page_code": UIViewController.wzCurPagePageCode,
                           @"source_code":UIViewController.wzLastBuriedPageCode,
                           @"enter_time":getCurrentTimeMillis(),
                           @"l_ver":kLogVersion,
                           }];
}

+ (void)didLeavePageVc:(UIViewController *)page
{
    NSString *title = page.navigationItem.title?:page.title;
    NSDictionary *dict = @{@"leave_time":getCurrentTimeMillis(), @"page_name":title?:NSStringFromClass([page class])};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *yyJsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WZLogInfo(@"%@ quit %@<%@> page^&^%@",kWzStatisticLogIdentifier, title, NSStringFromClass([page class]), yyJsonStr);
/*
    NSDictionary *buriedData = @{ @"phone_model":[WZStatisticHelper machineModelName],
                                                          @"os_type":@"iOS",
                                                          @"l_ver":kLogVersion,
                                                          @"uuid":HYDUserModelManagerShared.userModel.userId,
                                                          @"phone_num":HYDUserModelManagerShared.userModel.userPhone,
                                                          @"page_code": [NSString stringWithFormat:@"%@", [page class]],
                                                          @"source_code":UIViewController.wzLastBuriedPageCode?:@"",
                                                          @"enter_time":UIViewController.wzPageEnterTime,
                                                          @"leave_time":getCurrentTimeMillis(),
                                                          @"data":[UIViewController.wzBuriedEventDataBase copy],
                                                          };
    [self reportWithData:buriedData];
*/
    [UIViewController.wzBuriedEventDataBase removeAllObjects];
}

+ (void)recordWithWzTag:(NSString *)wzTag fromSender:(id)sender action:(SEL)action to:(id)target
{
    if ([self includeChineseInString:wzTag])  wzTag = [self transform2PinYin:wzTag];
    
    NSDictionary *btnBuryDict = nil;
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn =(UIButton *)sender;
        NSString *btnCode = wzTag?:[NSString stringWithFormat:@"%@%@%@%@",NSStringFromClass([target class]), [self transform2PinYin:btn.currentTitle], [self nameWithInstance:sender inTarget:target],[NSStringFromSelector(action) stringByReplacingOccurrencesOfString:@":" withString:@""]];
        NSDictionary *dict = @{@"code":btnCode,  @"value":btn.currentTitle?:btnCode, @"type":@"button",@"activate_time":getCurrentTimeMillis(),@"finish_time":getCurrentTimeMillis()};
        [UIViewController.wzBuriedEventDataBase addObject:dict];
        [WZStatisticHelper report2BigDataWithType:BigDataLogTypeClick data:@{@"t1":UIViewController.wzCurPagePageCode,@"t2":btnCode}];
        btnBuryDict = @{@"code":btnCode, @"value":btn.currentTitle?:btnCode};
    } else if ([sender isKindOfClass:[UITextField class]] || [sender isKindOfClass:[UITextView class]]) {
        UITextField *tf = (UITextField *)sender;
        NSString *tfCode = wzTag?:[NSString stringWithFormat:@"%@%@%@",NSStringFromClass([target class]),  [self nameWithInstance:sender inTarget:target],[NSStringFromSelector(action) stringByReplacingOccurrencesOfString:@":" withString:@""]];
        NSMutableDictionary *dict = [@{@"code":tfCode, @"value":tf.text, @"type":@"text", @"activate_time":getCurrentTimeMillis(),@"finish_time":getCurrentTimeMillis()} mutableCopy];
        NSDictionary *lastDict = UIViewController.wzBuriedEventDataBase.lastObject;
        if ([lastDict[@"type"] isEqualToString:@"text"] && [tfCode isEqualToString:lastDict[@"code"]]) {
            [dict setObject:lastDict[@"activate_time"] forKey:@"activate_time"];
            [UIViewController.wzBuriedEventDataBase replaceObjectAtIndex:UIViewController.wzBuriedEventDataBase.count-1 withObject:dict];
        } else {
            [UIViewController.wzBuriedEventDataBase addObject:dict];
        }
    } else if ([target isKindOfClass:[UICollectionView class]] || [target isKindOfClass:[UITableView class]]) {
        NSString *value = [NSString stringWithFormat:@"%@%@%@",NSStringFromClass([target class]), [self nameWithInstance:sender inTarget:target], [NSStringFromSelector(action) stringByReplacingOccurrencesOfString:@":" withString:@""]];
        NSDictionary *dict = @{@"code":wzTag?:value,  @"value":value, @"type":@"button",@"activate_time":getCurrentTimeMillis(),@"finish_time":getCurrentTimeMillis()};
        [UIViewController.wzBuriedEventDataBase addObject:dict];
        [WZStatisticHelper report2BigDataWithType:BigDataLogTypeClick data:@{@"t1":UIViewController.wzCurPagePageCode,@"t2":wzTag?:value}];
        btnBuryDict = @{@"code":wzTag?:value,  @"value":value};
    } else if ([sender isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
        NSString *btnName = @"";
        for (UIView *subView in [(UIControl *)sender subviews]) {
            if ([subView isKindOfClass:NSClassFromString(@"UITabBarButtonLabel")]){
                btnName = [subView valueForKeyPath:@"text"];
                break;
            }
        }
        NSString *btnCode = [NSString stringWithFormat:@"tabBtn_%@", [self transform2PinYin:btnName]];
        NSDictionary *dict = @{@"code":btnCode,  @"value":btnName, @"type":@"button",@"activate_time":getCurrentTimeMillis(),@"finish_time":getCurrentTimeMillis()};
        NSDictionary *lastDict = UIViewController.wzBuriedEventDataBase.lastObject;
        if (![btnCode isEqualToString:lastDict[@"code"]]) {
            [UIViewController.wzBuriedEventDataBase addObject:dict];
            [WZStatisticHelper report2BigDataWithType:BigDataLogTypeClick data:@{@"t1":UIViewController.wzCurPagePageCode,@"t2":btnCode}];
            btnBuryDict = @{@"code":btnCode, @"value":btnName};
        }
    } else if ([sender isKindOfClass:[UIView class]]) {
        UIView *view =(UIView *)sender;
        NSString *viewCode = wzTag?:[NSString stringWithFormat:@"%@%@%@",NSStringFromClass([target class]), [self nameWithInstance:sender inTarget:target],[NSStringFromSelector(action) stringByReplacingOccurrencesOfString:@":" withString:@""]];
        if ([view isKindOfClass:[UILabel class]]) {
            [viewCode stringByAppendingString:[(UILabel *)view text]];
        }
        NSDictionary *dict = @{@"code":viewCode,  @"value":viewCode, @"type":@"button",@"activate_time":getCurrentTimeMillis(),@"finish_time":getCurrentTimeMillis()};
        [UIViewController.wzBuriedEventDataBase addObject:dict];
        [WZStatisticHelper report2BigDataWithType:BigDataLogTypeClick data:@{@"t1":UIViewController.wzCurPagePageCode,@"t2":viewCode}];
        btnBuryDict = @{@"code":viewCode, @"value":viewCode};
    }
    
    if (btnBuryDict != nil) {
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:@{ @"phone_num":HYDUserModelManagerShared.userModel.userPhone,
                                                                                                                                                   @"page_code": [UIViewController wzCurPagePageCode],
                                                                                                                                                   @"activate_time":getCurrentTimeMillis(),
                                                                                                                                                   @"finish_time":getCurrentTimeMillis(),
                                                                                                                                                   @"l_ver":kLogVersion,
                                                                                                                                                   @"type":@"button",
                                                                                                                                                   }];
        [mDict addEntriesFromDictionary:btnBuryDict];
        [self reportWithData:mDict];
    }
}

+ (void)reportWithData:(NSDictionary *)data
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *uploadUrl = @"https://datahouse.hengyidai.com/dw/excute";
        if (kNetType != 2) {
            uploadUrl = @"http://10.100.19.69:8447/dw/excute";
        }
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithDictionary:@{ @"utmCode":@"201",
                                                                                        @"loanType":[kWzCurrentFlowType substringFromIndex:kWzCurrentFlowType.length-4],
                                                                                        @"osVersion":[NSString stringWithFormat:@"iOS_%@", [UIDevice currentDevice].systemVersion],
                                                                                        @"version":[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                                                                        @"deviceCode":[[APIRequestGenerator sharedInstance].commonParams objectForKey:@"deviceCode"],
                                                                                        @"tokenId":HYDUserModelManagerShared.userModel.tokenId}];
        [mDict addEntriesFromDictionary:data];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mDict options:NSJSONWritingPrettyPrinted error:nil];
        NSString *yyJsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        yyJsonStr = [yyJsonStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:[WZStatisticHelper URLRequestStringWithURL:uploadUrl params:@{@"jsonParams":yyJsonStr}]];
        NSURLRequest *request =[NSURLRequest requestWithURL:url];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if ((error || httpResponse.statusCode != 200) && kNetType != 2) {
//                WZLogError(@"upload hyd buried point error:%@",error);
            }
        }];
        [sessionDataTask resume];
    });
}

+ (void)report2BigDataWithType:(BigDataLogType)type data:(NSDictionary *)data
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
        NSString *yyJsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        yyJsonStr = [yyJsonStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSDictionary *sParam = @{@"deviceid":[[APIRequestGenerator sharedInstance].commonParams objectForKey:@"deviceCode"],
                                 @"phonenum":HYDUserModelManagerShared.userModel.userPhone,
                                 @"uid":HYDUserModelManagerShared.userModel.userId,
                                 @"pow":@([WZStatisticHelper getCurrentBatteryLevel]),
                                 @"m":kWzCurrentFlowType,
                                 @"t":(type==BigDataLogTypeClick)?@"cl":((type==BigDataLogTypePv)?@"pv":@"st"),
                                 @"l_ver":kBigDataLogVersion,
                                 @"p_url":UIViewController.wzCurPagePageCode,
                                 @"p_ref":UIViewController.wzLastBuriedPageCode,
                                 @"crt":getCurrentTimeMillis(),
                                 @"usc":@"201",
                                 @"cv":[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                 @"v":yyJsonStr
                                 };
        NSString *strURL = kNetType == 2 ? @"http://la.hengchang6.com/log.gif":@"http://10.150.26.166/log.gif";
        NSURL *url = [NSURL URLWithString:[WZStatisticHelper URLRequestStringWithURL:strURL params:sParam]];
        NSURLRequest *request =[NSURLRequest requestWithURL:url];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if ((error || httpResponse.statusCode != 200) && kNetType != 2) {
//                WZLogError(@"upload bigdata buried point error:%@",error);
            }
        }];
        [sessionDataTask resume];
    });
}

#pragma mark -- private method
/*
    当以下几个产品的介绍页面开始时即代表这个流程的开始，直至下一个产品介绍页面出现作为上一个流程的终止；
    以下type后四位编码和后台以及工程中定义的LoanType保持一致。
 */
+ (void)setWzCurrentFlowTypeWithPageVC:(UIViewController *)page
{
    NSString *PageName = NSStringFromClass([page class]);
    if ([PageName isEqualToString:@"HYDJSDProductInfoViewController"]) {
        kWzCurrentFlowType = @"LA-3-003-01001";//即速贷
    } else if ([PageName isEqualToString:@"HYDSBDProductInfoViewController"]) {
        kWzCurrentFlowType = @"LA-3-003-01002";//社保贷
    } else if ([PageName isEqualToString:@"HYDGJJDProductInfoViewController"]) {
        kWzCurrentFlowType = @"LA-3-003-01004";//公积金贷
    } else if ([PageName isEqualToString:@"HYDNSDInfoViewController"]) {
        kWzCurrentFlowType = @"LA-3-003-01201";//女神贷
    } else if ([PageName isEqualToString:@"HYDCEDInfoViewController"]) {
        kWzCurrentFlowType = @"LA-3-003-01202";//超E代
    } else if ([PageName isEqualToString:@"HYDHCRInfoViewController"]) {
        kWzCurrentFlowType = @"LA-3-003-01101";//恒车融
    } else if ([PageName isEqualToString:@"HYDZYDInfoViewController"]) {
        kWzCurrentFlowType = @"LA-3-003-01102";//中易贷
    } else if ([PageName isEqualToString:@"HYDDXDViewController"]) {
        kWzCurrentFlowType = @"LA-3-003-02000";//电销贷
    } else if ([PageName isEqualToString:@"暂无Q贷介绍页面"]) {
        kWzCurrentFlowType = @"LA-3-003-01301";//Q贷
    } else if ([PageName isEqualToString:@"HYDProductInfoController"]) {
        NSInteger loantype = [[page valueForKey:@"loanType"] integerValue];
        if (loantype == 1010) {
            kWzCurrentFlowType = @"LA-3-003-01010";//新即速贷
        } else if (loantype == 1210) {
            kWzCurrentFlowType = @"LA-3-003-01210";//新Q贷
        }
    }
}

+ (NSString *)URLRequestStringWithURL:(NSString *)urlstr params:(NSDictionary *)aParams
{
    NSMutableString *URL = [NSMutableString stringWithFormat:@"%@",urlstr];
    NSArray * keys = [aParams allKeys];
    for (int j = 0; j < keys.count; j ++){
        NSString *string;
        if (j == 0){
            string = [NSString stringWithFormat:@"?%@=%@", keys[j], aParams[keys[j]]];
        }else{
            string = [NSString stringWithFormat:@"&%@=%@", keys[j], aParams[keys[j]]];
        }
        [URL appendString:string];
    }
    return URL;
}

+ (int)getCurrentBatteryLevel
{
    UIApplication *app = [UIApplication sharedApplication];
    if (app.applicationState == UIApplicationStateActive||app.applicationState==UIApplicationStateInactive) {
        Ivar ivar=  class_getInstanceVariable([app class],"_statusBar");
        id status  = object_getIvar(app, ivar);
        for (id aview in [status subviews]) {
            int batteryLevel = 0;
            for (id bview in [aview subviews]) {
                if ([NSStringFromClass([bview class]) caseInsensitiveCompare:@"UIStatusBarBatteryItemView"] == NSOrderedSame&&[[[UIDevice currentDevice] systemVersion] floatValue] >=6.0) {
                    Ivar ivar=  class_getInstanceVariable([bview class],"_capacity");
                    if(ivar) {
                        batteryLevel = ((int (*)(id, Ivar))object_getIvar)(bview, ivar);
                        if (batteryLevel > 0 && batteryLevel <= 100) {
                            return batteryLevel;
                        } else {
                            return 0;
                        }
                    }
                }
            }
        }
    }
    return 0;
}

+ (BOOL)includeChineseInString:(NSString *)string
{
    if (![string isKindOfClass:[NSString class]] || string == nil || string.length == 0) {
        return NO;
    }
    for(int i=0; i< [string length];i++) {
        int a =[string characterAtIndex:i];
        if(a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}

+ (NSString *)transform2PinYin:(NSString *)chinese
{
    if (!chinese || chinese.length == 0) {
        return @"";
    }
    
    if (![self includeChineseInString:chinese]) {
        return chinese;
    }
        //将NSString装换成NSMutableString
    NSMutableString *pinyin = [chinese mutableCopy];
        //将汉字转换为拼音(带音标)
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
        //去掉拼音的音标
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return [pinyin stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (NSString *)nameWithInstance:(id)instance inTarget:(id)target
{
    unsigned int numIvars = 0;
    NSString *key=nil;
    Ivar *ivars = class_copyIvarList([target class], &numIvars);
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = ivars[i];
        const char *type = ivar_getTypeEncoding(thisIvar);
        NSString *stringType =  [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        if (![stringType hasPrefix:@"@"]) {
            continue;
        }
        if ((object_getIvar(target, thisIvar) == instance)) {
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivars);
    return key?:@"";
}

+ (NSString *)machineModel
{
    static dispatch_once_t one;
    static NSString *model;
    dispatch_once(&one, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        model = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return model;
}

+ (NSString *)machineModelName
{
    static dispatch_once_t one;
    static NSString *name;
    dispatch_once(&one, ^{
        NSString *model = [self machineModel];
        if (!model) return;
        NSDictionary *dic = @{
                              @"Watch1,1" : @"Apple Watch 38mm",
                              @"Watch1,2" : @"Apple Watch 42mm",
                              @"Watch2,3" : @"Apple Watch Series 2 38mm",
                              @"Watch2,4" : @"Apple Watch Series 2 42mm",
                              @"Watch2,6" : @"Apple Watch Series 1 38mm",
                              @"Watch1,7" : @"Apple Watch Series 1 42mm",
                              
                              @"iPod1,1" : @"iPod touch 1",
                              @"iPod2,1" : @"iPod touch 2",
                              @"iPod3,1" : @"iPod touch 3",
                              @"iPod4,1" : @"iPod touch 4",
                              @"iPod5,1" : @"iPod touch 5",
                              @"iPod7,1" : @"iPod touch 6",
                              
                              @"iPhone1,1" : @"iPhone 1G",
                              @"iPhone1,2" : @"iPhone 3G",
                              @"iPhone2,1" : @"iPhone 3GS",
                              @"iPhone3,1" : @"iPhone 4 (GSM)",
                              @"iPhone3,2" : @"iPhone 4",
                              @"iPhone3,3" : @"iPhone 4 (CDMA)",
                              @"iPhone4,1" : @"iPhone 4S",
                              @"iPhone5,1" : @"iPhone 5",
                              @"iPhone5,2" : @"iPhone 5",
                              @"iPhone5,3" : @"iPhone 5c",
                              @"iPhone5,4" : @"iPhone 5c",
                              @"iPhone6,1" : @"iPhone 5s",
                              @"iPhone6,2" : @"iPhone 5s",
                              @"iPhone7,1" : @"iPhone 6 Plus",
                              @"iPhone7,2" : @"iPhone 6",
                              @"iPhone8,1" : @"iPhone 6s",
                              @"iPhone8,2" : @"iPhone 6s Plus",
                              @"iPhone8,4" : @"iPhone SE",
                              @"iPhone9,1" : @"iPhone 7",
                              @"iPhone9,2" : @"iPhone 7 Plus",
                              @"iPhone9,3" : @"iPhone 7",
                              @"iPhone9,4" : @"iPhone 7 Plus",
                              
                              @"iPad1,1" : @"iPad 1",
                              @"iPad2,1" : @"iPad 2 (WiFi)",
                              @"iPad2,2" : @"iPad 2 (GSM)",
                              @"iPad2,3" : @"iPad 2 (CDMA)",
                              @"iPad2,4" : @"iPad 2",
                              @"iPad2,5" : @"iPad mini 1",
                              @"iPad2,6" : @"iPad mini 1",
                              @"iPad2,7" : @"iPad mini 1",
                              @"iPad3,1" : @"iPad 3 (WiFi)",
                              @"iPad3,2" : @"iPad 3 (4G)",
                              @"iPad3,3" : @"iPad 3 (4G)",
                              @"iPad3,4" : @"iPad 4",
                              @"iPad3,5" : @"iPad 4",
                              @"iPad3,6" : @"iPad 4",
                              @"iPad4,1" : @"iPad Air",
                              @"iPad4,2" : @"iPad Air",
                              @"iPad4,3" : @"iPad Air",
                              @"iPad4,4" : @"iPad mini 2",
                              @"iPad4,5" : @"iPad mini 2",
                              @"iPad4,6" : @"iPad mini 2",
                              @"iPad4,7" : @"iPad mini 3",
                              @"iPad4,8" : @"iPad mini 3",
                              @"iPad4,9" : @"iPad mini 3",
                              @"iPad5,1" : @"iPad mini 4",
                              @"iPad5,2" : @"iPad mini 4",
                              @"iPad5,3" : @"iPad Air 2",
                              @"iPad5,4" : @"iPad Air 2",
                              @"iPad6,3" : @"iPad Pro (9.7 inch)",
                              @"iPad6,4" : @"iPad Pro (9.7 inch)",
                              @"iPad6,7" : @"iPad Pro (12.9 inch)",
                              @"iPad6,8" : @"iPad Pro (12.9 inch)",
                              
                              @"AppleTV2,1" : @"Apple TV 2",
                              @"AppleTV3,1" : @"Apple TV 3",
                              @"AppleTV3,2" : @"Apple TV 3",
                              @"AppleTV5,3" : @"Apple TV 4",
                              
                              @"i386" : @"Simulator x86",
                              @"x86_64" : @"Simulator x64",
                              };
        name = dic[model];
        if (!name) name = model;
    });
    return name;
}

@end

