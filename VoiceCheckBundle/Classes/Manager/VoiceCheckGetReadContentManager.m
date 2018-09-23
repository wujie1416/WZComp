//
//  VoiceCheckGetReadContentManager.m
//  AFNetworking
//
//  Created by wujie on 2018/5/24.
//

#import "VoiceCheckGetReadContentManager.h"
#import "YYKit.h"
#import "UtilsMacro.h"

@implementation VoiceCheckGetReadContentManager

- (NSString *)methodName
{
    return @"/platform/app/voice/getReadContent";
}


- (NSDictionary *)inputParameter
{
    return @{
             @"userName":self.userName
             };
}

/**
 *  设置域名
 */
- (HYDServiceType)serviceType
{
    return ServiceTypeJsd;
}

- (NSString *)dataStr
{
    NSTimeInterval interval =[_dataStr doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate: date];
    return dateString;
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
            self.contentId = [self.retDict stringValueForKey:@"id" default:@"1"];
            self.content = [self.retDict stringValueForKey:@"content" default:@"1"];
            self.minTime = [self.retDict integerValueForKey:@"minTime" default:30];
            self.maxTime = [self.retDict integerValueForKey:@"maxTime" default:60];
            self.dataStr = [self.retDict stringValueForKey:@"data" default:@"1527561121000"];
        }
    } else {
        err = [[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeNoContent userInfo:@{kErrorMsgKey:@{@"rspCode":@(self.retModel.rspCode),
                                                                                                                       @"rspMsg":self.retModel.rspMsg?:@"err null",
                                                                                                                       @"showMsg":self.retModel.showMsg?:@"err null"}}];
    }
    return err;
}
@end
