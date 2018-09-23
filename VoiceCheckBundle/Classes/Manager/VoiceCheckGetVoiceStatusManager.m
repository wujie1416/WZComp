//
//  VoiceCheckGetVoiceStatusManager.m
//  AFNetworking
//
//  Created by wujie on 2018/5/24.
//

#import "VoiceCheckGetVoiceStatusManager.h"
#import "YYKit.h"
#import "UtilsMacro.h"

@implementation VoiceCheckGetVoiceStatusManager
- (NSString *)methodName
{
    return @"/platform/app/voice/getVoiceStatus";
}

/**
 *  设置域名
 */
- (HYDServiceType)serviceType
{
    return ServiceTypeJsd;
}

- (NSString *)ymdStr
{
    NSTimeInterval interval =[_uploadTime doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate: date];
    return dateString;
}

- (NSString *)hmsStr
{
    NSTimeInterval interval =[_uploadTime doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateFormat:@"HH:mm:ss"];
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
            self.valid = [self.retDict stringValueForKey:@"valid" default:@""];
            self.describ = [self.retDict stringValueForKey:@"describ" default:@""];
            self.uploadTime = [self.retDict stringValueForKey:@"uploadTime" default:@"1527561121000"];
        }
    } else {
        err = [[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeNoContent userInfo:@{kErrorMsgKey:@{@"rspCode":@(self.retModel.rspCode),
                                                                                                                       @"rspMsg":self.retModel.rspMsg?:@"err null",
                                                                                                                       @"showMsg":self.retModel.showMsg?:@"err null"}}];
    }
    return err;
}
@end
