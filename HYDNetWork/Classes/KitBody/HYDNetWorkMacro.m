//
//  HYDNetWorkMacro.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "HYDNetWorkMacro.h"
#import "APIRequestGenerator.h"

//生产
NSString *const HYD_Produce_HYD_Host       = @"https://hyd.hengchang6.com";
NSString *const HYD_Produce_JSD_Host       = @"https://hyd.hengchang6.com";
NSString *const HYD_Produce_Help_Host      = @"https://hyd.hengchang6.com";
NSString *const HYD_Produce_Solo_Host      = @"https://applynew.hengchang6.com";

//UAT预发布
NSString *const HYD_UAT_HYD_Host           = @"http://10.100.13.50";
NSString *const HYD_UAT_JSD_Host           = @"http://10.100.13.50";
NSString *const HYD_UAT_Help_Host          = @"http://10.100.19.110";
NSString *const HYD_UAT_Solo_Host          = @"http://10.150.26.156:8080";

//测试&开发
NSString *const HYD_Test_HYD_Host          = @"http://10.150.26.249";
NSString *const HYD_Test_JSD_Host          = @"http://10.150.26.249";
NSString *const HYD_Test_Help_Host         = @"http://10.100.19.110";
NSString *const HYD_Test_Solo_Host         = @"http://10.150.26.156:8080";


@interface HYDNetWorkMacro ()

@property (nonatomic, assign) HYDServiceEnvironmentType type;
@property (nonatomic, copy) NSString *hostHyd;
@property (nonatomic, copy) NSString *hostHydJsd;
@property (nonatomic, copy) NSString *hostHydHelp;
@property (nonatomic, copy) NSString *hostHydSolo;
@property (nonatomic, copy) NSString *hostHydCustom;

@end


@implementation HYDNetWorkMacro

+ (void)load
{
    [HYDNetWorkMacro sharedNetWorkMacro];
}

+ (HYDNetWorkMacro *)sharedNetWorkMacro
{
    static HYDNetWorkMacro *netWorkMacro = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        netWorkMacro = [[self alloc] init];
    });
    return netWorkMacro;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpWithServiceEnvironmentType:kNetType];
    }
    return self;
}

+ (void)setRequestCommonParams:(NSDictionary *)params
{
    [[APIRequestGenerator sharedInstance] setCommonParams:params];
}

+ (void)setRequestTokenId:(NSString *)tokenId deviceCode:(NSString *)deviceCode
{
    [[APIRequestGenerator sharedInstance] setCommonParams:@{@"tokenId":tokenId?:@"",@"deviceCode":deviceCode?:@""}];
}

- (void)setUpWithServiceEnvironmentType:(HYDServiceEnvironmentType)type
{
    _type = type;
    switch (type) {
        case ServiceEnvironmentTypeProduce:
        {
            _hostHyd = HYD_Produce_HYD_Host;
            _hostHydJsd = HYD_Produce_JSD_Host;
            _hostHydHelp = HYD_Produce_Help_Host;
            _hostHydSolo = HYD_Produce_Solo_Host;
        }
            break;
        case ServiceEnvironmentTypeTest:
        {
            _hostHyd = HYD_Test_HYD_Host;
            _hostHydJsd = HYD_Test_JSD_Host;
            _hostHydHelp = HYD_Test_Help_Host;
            _hostHydSolo = HYD_Test_Solo_Host;
        }
            break;
        case ServiceEnvironmentTypePre_release:
        {
            _hostHyd = HYD_UAT_HYD_Host;
            _hostHydJsd = HYD_UAT_JSD_Host;
            _hostHydHelp = HYD_UAT_Help_Host;
            _hostHydSolo = HYD_UAT_Solo_Host;
        }
            break;
        case ServiceEnvironmentTypeCustom:
        {
            _hostHyd = HYD_Test_HYD_Host;
            _hostHydJsd = HYD_Test_JSD_Host;
            _hostHydHelp = HYD_Test_Help_Host;
            _hostHydSolo = HYD_Test_Solo_Host;
        }
            break;
    }
}

- (void)setUpWithUrlHostType:(HYDServiceType)type host:(NSString *)host
{
    if (_type == ServiceEnvironmentTypeCustom) {
        switch (type) {
            case ServiceTypeBase:
                _hostHyd = host;
                break;
            case ServiceTypeJsd:
                _hostHydJsd = host;
                break;
            case ServiceTypeHelp:
                _hostHydHelp = host;
                break;
            case ServiceTypeSolo:
                _hostHydSolo = host;
                break;
            case ServiceTypeCustom:
                _hostHydCustom = host;
                break;
            default:
                break;
        }
    }
    if (type == ServiceTypeCustom) {
        _hostHydCustom = host;
    }
}

+ (NSString *)getUrlHostWithServiceType:(HYDServiceType)type
{
    HYDNetWorkMacro *shared = [HYDNetWorkMacro sharedNetWorkMacro];
    switch (type) {
        case ServiceTypeBase:
            return shared.hostHyd;
        case ServiceTypeJsd:
            return shared.hostHydJsd;
        case ServiceTypeHelp:
            return shared.hostHydHelp;
        case ServiceTypeSolo:
            return shared.hostHydSolo;
        case ServiceTypeCustom:
            return shared.hostHydCustom;
    }
}

- (HYDServiceEnvironmentType)getCurrentServiceEnvironment
{
    return _type;
}
@end
