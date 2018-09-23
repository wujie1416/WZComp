//
//  HYDCrashHandler.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/5/12.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "WZCrashHandler.h"
#import "ApiHttpRequestUtil.h"
#import "APIURLResponse.h"
#import "HYDLSUserManager.h"
#import "GlobalUnique.h"
#import <sys/utsname.h>
#include <sys/sysctl.h>
#import <UIKit/UIKit.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import <objc/runtime.h>

NSString *const kHydCrashModelKey = @"Hyd-crash";

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";
volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;
const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@implementation WZCrashHandler

//手动记录一个错误信息上报到crash日志服务器
+ (void)manualRecodeErrorWithName:(NSString *)name reason:(NSString *)reason userInfo:(NSDictionary *)userInfo
{
    NSException *exception = [NSException exceptionWithName:name reason:reason userInfo:userInfo];
    [[WZCrashHandler defaultManager] recodeHYDCrashErrorWith:exception];
}

void getAnCrashErrorHandler(NSException *exception)
{
    [[WZCrashHandler defaultManager] performSelectorOnMainThread:@selector(recodeHYDCrashErrorWith:) withObject:exception waitUntilDone:YES];
}

+ (void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self defaultManager] uploadLastCrashInfo];
    });
}

+ (instancetype)defaultManager {
    static WZCrashHandler *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] init];
    });
    return mgr;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSSetUncaughtExceptionHandler(&getAnCrashErrorHandler);
        signal(SIGABRT, hydSignalHandler);
        signal(SIGILL, hydSignalHandler);
        signal(SIGSEGV, hydSignalHandler);
        signal(SIGFPE, hydSignalHandler);
        signal(SIGBUS, hydSignalHandler);
        signal(SIGPIPE, hydSignalHandler);
    }
    return self;
}


- (void)uploadLastCrashInfo
{
    NSString *crash = [[NSUserDefaults standardUserDefaults] objectForKey:kHydCrashModelKey];
    if (crash == nil || [crash isEqualToString:@""]) {
        return;
    }
    if (kNetType != 2) {
        WZLogInfo(@"failed <crashed has happed>:%@", crash);
        return;
    }
    
    NSString *crashLog = [NSString stringWithFormat:@"[%@]", crash];
    ApiHttpRequestUtil *requestUtil = [[ApiHttpRequestUtil alloc] init];
    [requestUtil callPOSTWithUrl:@"https://crash.hengchang6.com/crashLog/sendCrashLog" params:@{@"crashlogs":crashLog} extraParams:nil success:^(id response, NSURLRequest *request) {
        APIURLResponse *urlResonse = (APIURLResponse *)response;
        NSDictionary *subDict = urlResonse.content;
        if ([subDict[@"rspCode"] integerValue] == 200) {
            WZLogInfo(@"upload crash log success and crashInfo is:%@",crashLog);
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kHydCrashModelKey];
        } else {
            WZLogError(@"upload crash log failed and crashInfo is:%@ and response is %@",crashLog, response);
        }
    } fail:^(id response, NSURLRequest *request) {
        WZLogError(@"upload crash log failed and crashInfo is:%@ and response is %@",crashLog, response);
    }];
}

- (void)recodeHYDCrashErrorWith:(NSException*)exception
{
    //统计崩溃时间。
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [formatter stringFromDate:date];
    //统计设备信息和系统信息
    UIDevice *device = [UIDevice currentDevice];
    NSString *iphone = [self machineModelName];
    NSArray *stackSymbol = [exception callStackSymbols];
    
    NSString *stack = @"";
    for (NSString *stackSr in stackSymbol) {
        stack =  [stack stringByAppendingFormat:@"%@\\n",stackSr];
    }
    
    NSString *applicationVersion =   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *applicationBundle = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSMutableArray *mutArray = [NSMutableArray array];
    
    [mutArray addObject:[NSString stringWithFormat:@"\"appBundle\":\"%@\"",applicationBundle]];
    [mutArray addObject:[NSString stringWithFormat:@"\"appVersion\":\"%@\"",applicationVersion]];
    [mutArray addObject:@"\"appType\":\"hyd\""];
    [mutArray addObject:@"\"osType\":\"ios\""];
    [mutArray addObject:[NSString stringWithFormat:@"\"deviceModel\":\"%@\"",iphone]];
    [mutArray addObject:[NSString stringWithFormat:@"\"osVersion\":\"%@\"",device.systemVersion]];
    [mutArray addObject:[NSString stringWithFormat:@"\"timeStr\":\"%@\"",time]];
    [mutArray addObject:[NSString stringWithFormat:@"\"crashType\":\"%@\"", [exception name]]];
    [mutArray addObject:[NSString stringWithFormat:@"\"message\":\"%@\"",exception.reason]];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:exception.userInfo?:@{} options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [mutArray addObject:[NSString stringWithFormat:@"\"detail\":\"%@\"",[stack stringByAppendingString:json?:@""]]];
    [mutArray addObject:[NSString stringWithFormat:@"\"userName\":\"%@\"",HYDUserModelManagerShared.userModel.userName]];
    [mutArray addObject:[NSString stringWithFormat:@"\"userId\":\"%@\"",HYDUserModelManagerShared.userModel.userId]];
    
    
    NSString *CRASHStr = [mutArray componentsJoinedByString:@","];
    CRASHStr = [NSString stringWithFormat:@"{%@}",CRASHStr];

    NSString *HydCrash = [[NSUserDefaults standardUserDefaults] objectForKey:kHydCrashModelKey];
    if (HydCrash && ![HydCrash isEqualToString:@""]) {
        CRASHStr = [NSString stringWithFormat:@"%@,%@",HydCrash,CRASHStr];
    }
    [[NSUserDefaults standardUserDefaults] setObject:CRASHStr forKey:kHydCrashModelKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    WZLogInfo(@"app failed! crash has happened: %@", CRASHStr);
}

void hydSignalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    NSArray *callStack = [WZCrashHandler backtrace];
    [userInfo setObject:callStack?:@[] forKey:UncaughtExceptionHandlerAddressesKey];
    [[[WZCrashHandler alloc] init] performSelectorOnMainThread:@selector(recodeHYDCrashErrorWith:)
     withObject: [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                                         reason: [NSString stringWithFormat:NSLocalizedString(@"Signal %d was raised.\n"@"%@%@",nil),signal, getAppInfo(),callStack]
                  
                                       userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:signal]
                                                                            forKey:UncaughtExceptionHandlerSignalKey]]waitUntilDone:YES];
}

NSString* getAppInfo()
{
    NSString *appInfo = [NSString stringWithFormat:@"App :%@ %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\nUDID :\n",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                         [UIDevice currentDevice].model,
                         [UIDevice currentDevice].systemName,
                         [UIDevice currentDevice].systemVersion,
                         [UIDevice keyChainUUID]];
    WZLogError(@"Crash!!!! %@", appInfo);
    return appInfo;
}

+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (
         i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount +
         UncaughtExceptionHandlerReportAddressCount;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}

- (NSString *)machineModel {
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

- (NSString *)machineModelName {
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
