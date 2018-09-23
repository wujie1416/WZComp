//
//  TPJSToNAExtension.m
//  HC_PromoteBusiness
//
//  Created by ztp on 16/10/26.
//  Copyright © 2016年 ztp. All rights reserved.
//

#import "TPJSToNAExtension.h"
#import <WZLocationHelper/WZLocationHelper.h>
#import <WZLogger/WZLogging.h>

@interface TPJSToNAExtension()
@property (nonatomic,strong) NSDictionary *dataDict; //协议中参数
@end

@implementation TPJSToNAExtension


- (void)createJScontextWithWebView:(UIWebView *)webview
{
    self.jsContext                  = [webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    // 打印JS运行时候的异常
    self.jsContext.exceptionHandler =
    ^(JSContext *context, JSValue *exceptionValue) {
        context.exception           = exceptionValue;
        WZLogError(@"错误描述====%@", exceptionValue);
    };
    
}

// Native给JS传参数
- (void)runJSCallBackWithData:(NSString *)dataStr andMethod:(NSString *)method
{
    //获取JS方法 dataStr 为传参。method 为对应方法
    JSValue *function   = [self.jsContext objectForKeyedSubscript:method];
    //function 是方法对象，inputNumber是方法的参量
    JSValue *result     = [function callWithArguments:@[dataStr]];
    NSString *name      = [NSString stringWithFormat:@"%@", [result toNumber]];
    WZLogInfo(@"%@",name);
}

//接收协议
- (BOOL)StartJStoNativeWithURLString:(NSString *)urlString
{
    BOOL startAction        = YES;//执行动作
    if([urlString rangeOfString:@"hengchang://puhui.com/?"].location !=NSNotFound){
        urlString           = [urlString stringByReplacingOccurrencesOfString:@"hengchang://puhui.com/?hc_parms=" withString:@""];
        urlString           = [self decodeFromPercentEscapeString:urlString];
        NSDictionary * dict = [self dictionaryWithJsonString:urlString];
        //根据协议对应的参数执行对应的业务方法
        [self dealWithType:dict];
        WZLogInfo(@"webView receive h5 msg:%@ and dataDict is:%@",urlString, dict);
    }else{
        startAction = NO;//无执行动作
    }
   return startAction;
}

- (NSString *)stringValueInDict:(NSDictionary *)dict forKey:(NSString *)key default:(NSString *)def {
    if (!key) return def;
    id value = dict[key];
    if (!value || value == [NSNull null]) return def;
    if ([value isKindOfClass:[NSString class]]) return value;
    if ([value isKindOfClass:[NSNumber class]]) return ((NSNumber *)value).description;
    return def;
}

//根据协议对应的参数执行对应的业务方法
- (void)dealWithType:(NSDictionary*)dict
{
    self.dataDict = dict;
    //接入分享功能 dict里面有对应需要的参数
    if ([[dict objectForKey:@"type"]isEqualToString:@"share"]) {
        [self startShareOutWithDict:[dict objectForKey:@"data"]];
        //接入获取地理位置功能
    } else if ([[dict objectForKey:@"type"]isEqualToString:@"location"]) {
        [self getLocation];
        //短信
    } else if ([[dict objectForKey:@"type"]isEqualToString:@"sms"]) {
        NSDictionary *data = [dict objectForKey:@"data"];
        NSString *phone = [self stringValueInDict:data forKey:@"phoneNumber" default:@""];
        NSString *content = [self stringValueInDict:data forKey:@"content" default:@""];
        if(self.smsBlock){
            self.smsBlock(phone,content);
        }
    } else if ([[dict objectForKey:@"type"]isEqualToString:@"jumpapplogin"]) {
        NSDictionary *data = [dict objectForKey:@"data"];
        NSString *result = [self stringValueInDict:data forKey:@"result" default:@""];
        if(self.accitionBlock && [result isEqualToString:@"1"]){
            self.accitionBlock(dict,@"jumpapplogin",result);
        }
    } else if ([[dict objectForKey:@"type"]isEqualToString:@"navigation"]) {
        NSDictionary *data = [dict objectForKey:@"data"];
        NSString *str = [self stringValueInDict:data forKey:@"name" default:@""];
        if(self.accitionBlock){
            self.accitionBlock(dict,str,nil);
        }
        //调用原生打电话功能
    } else if ([[dict objectForKey:@"type"] isEqualToString:@"tel"]) {
        NSDictionary *data = [dict objectForKey:@"data"];
        NSString *result = [self stringValueInDict:data forKey:@"phone" default:@""];
        if(self.accitionBlock){
            self.accitionBlock(dict,@"tel", result);
        }
        //中易贷-房产信息
    } else if ([[dict objectForKey:@"type"] isEqualToString:@"housesave"]) {
        NSDictionary *data = [dict objectForKey:@"data"];
        NSString *result = [self stringValueInDict:data forKey:@"result" default:@""];
        if(self.accitionBlock){
            self.accitionBlock(dict,@"housesave", result);
        }
        //密码管理-修改交易密码
    } else if ([[dict objectForKey:@"type"] isEqualToString:@"gzTransPassModify"]) {
        NSDictionary *data = [dict objectForKey:@"data"];
        NSString *result = [self stringValueInDict:data forKey:@"result" default:@""];
        if(self.accitionBlock){
            self.accitionBlock(dict,@"gzTransPassModify", result);
        }
        
        //首页极速贷banner-进入即速贷组件
    } else if ([[dict objectForKey:@"type"] isEqualToString:@"jsd"]) {
        NSDictionary *data = [dict objectForKey:@"data"];
        NSString *result = [self stringValueInDict:data forKey:@"result" default:@""];
        if(self.accitionBlock && [result isEqualToString:@"1"]){
            self.accitionBlock(dict,@"jsd", result);
        }
        //爱奇艺会员运营活动-进入极速贷组件
    } else if ([[dict objectForKey:@"type"] isEqualToString:@"eventjsd"]) {
        NSDictionary *data = [dict objectForKey:@"data"];
        NSString *result = [self stringValueInDict:data forKey:@"result" default:@""];
        if(self.accitionBlock){
            self.accitionBlock(dict,@"eventjsd", result);
        }
        //红包 参数redpacketid:红包ID
    } else if ([[dict objectForKey:@"type"] isEqualToString:@"redPacket"]) {
        NSDictionary *data = [dict objectForKey:@"data"];
        NSString *result = [self stringValueInDict:data forKey:@"redpacketid" default:@""];
        if(self.accitionBlock){
            self.accitionBlock(dict,@"redPacket", result);
        }
        //其他
    } else {
        if(self.accitionBlock){
            self.accitionBlock(dict,@"",nil);
        }
    }
}


//******************************************执行获取地理位置方法。得到参数传给JS******************************
- (void)getLocation
{
    self.cityName = [WZLocationHelper sharedLocation].myLocation?:@"北京市";
    [self runJSCallBackWithData:self.cityName andMethod:[self.dataDict objectForKey:@"callback"]];
}

//******************************************执行分享功能******************************************
- (void)startShareOutWithDict:(NSDictionary*)dict
{
    self.shareTitle    = [self stringValueInDict:dict forKey:@"title" default:@""];
    self.shareContent  = [self stringValueInDict:dict forKey:@"content" default:@""];
    self.shareImgUrl   = [self stringValueInDict:dict forKey:@"imgurl" default:@""];
    self.shareUrl      = [self stringValueInDict:dict forKey:@"pagelink" default:@""];
    NSMutableDictionary *Dict = [[NSMutableDictionary alloc]init];
    [Dict setValue:self.shareTitle forKey:@"title"];
    [Dict setValue:self.shareContent forKey:@"content"];
    [Dict setValue:self.shareImgUrl forKey:@"imgurl"];
    [Dict setValue:self.shareUrl forKey:@"shareUrl"];
    if(self.shareBlock) {
        self.shareBlock(Dict);
    }

    //开始分享......
}
//解除URL中Escape编码
- (NSString *)decodeFromPercentEscapeString:(NSString *)input
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
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
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
        WZLogError(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
