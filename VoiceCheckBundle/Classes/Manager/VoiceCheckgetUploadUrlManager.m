//
//  VoiceCheckgetUploadUrlManager.m
//  AFNetworking
//
//  Created by wujie on 2018/5/31.
//

#import "VoiceCheckgetUploadUrlManager.h"
#import "YYKit.h"
#import "UtilsMacro.h"
//#import "HYDLSUserManager.h"

@implementation VoiceCheckgetUploadUrlManager

- (NSString *)methodName
{
    return @"/jsd/app/fileUpload/getUploadUrl";
}

- (NSDictionary *)inputParameter
{
    return @{
             @"userId":self.userId,
             @"category":@"voice",
             @"apiVersion":@"ver2"
             };
}

/**
 *  设置域名
 */
- (HYDServiceType)serviceType
{
    return ServiceTypeJsd;
}

/**
 *  网络请求应答正确校验回调， 正确返回nil，错误返回error
 */
- (NSError *)isResponseError:(APIURLResponse *)response
{
    NSError *err = nil;
    NSDictionary *outputDict = (NSDictionary *)response.content;
    self.retModel = [APIModel modelWithJSON:outputDict];
    if (self.retModel.rspCode == 200) {
        NSDictionary *data = self.retModel.data;
        if (NO == DictionaryIsNullOrEmpty(data)) {
            self.retDict = [data copy];
            self.url = [self.retDict stringValueForKey:@"url" default:@""];
        }
    } else {
        err = [[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeNoContent userInfo:@{kErrorMsgKey:@{@"rspCode":@(self.retModel.rspCode),
                                                                                                                       @"rspMsg":self.retModel.rspMsg?:@"err null",
                                                                                                                       @"showMsg":self.retModel.showMsg?:@"err null"}}];
    }
    return err;
}
@end
