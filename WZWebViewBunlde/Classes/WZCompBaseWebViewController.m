//
//  HYDBaseWebViewController.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/29.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "WZCompBaseWebViewController.h"
#import "HYDNetWorkMacro.h"
@interface WZCompBaseWebViewController ()
@end

@implementation WZCompBaseWebViewController

#pragma mark -- lifeCircle

- (id)initWithLoanType:(LoanType)loanType loanId:(NSString *)loanId unitCode:(NSString *)unitCode completedBlock:(void(^)(BOOL result, id data))block
{
    return [self initWithLoanType:loanType loanId:loanId flowId:@"" unitCode:unitCode completedBlock:block];
}

- (id)initWithLoanType:(LoanType)loanType loanId:(NSString *)loanId flowId:(NSString *)flowId unitCode:(NSString *)unitCode navTitle:(NSString *)title webUrl:(NSString *)webUrl postRequestParameter:(NSString *)params completedBlock:(void(^)(BOOL result, id data))block
{
    if (self = [self initWithLoanType:loanType loanId:loanId flowId:flowId unitCode:unitCode completedBlock:block]) {
        self.navTitle = title;
        self.webUrl = webUrl;
        self.parameter = params;
        self.showCloseBtn = YES;
        self.showBackBtn = YES;
        self.goBackEnable = YES;
    }
    return self;
}


- (id)initWithLoanType:(LoanType)loanType loanId:(NSString *)loanId flowId:(NSString *)flowId unitCode:(NSString *)unitCode completedBlock:(void(^)(BOOL result, id data))block
{
    return [self initWithLoanType:loanType loanId:loanId flowId:flowId unitCode:unitCode urlMap:@{} completedBlock:block];
}

- (id)initWithLoanType:(LoanType)loanType loanId:(NSString *)loanId flowId:(NSString *)flowId unitCode:(NSString *)unitCode urlMap:(NSDictionary *)urlMap completedBlock:(void(^)(BOOL result, id data))block
{
    if (self = [super init]) {
        _loanId = loanId;
        _flowId = flowId;
        _unitCode = unitCode;
        _loanType = loanType;
        _urlMap = urlMap;
        _completedBlock = block;
    }
    return self;
}

- (void)dealloc
{
    if (_completedBlock) {
        _completedBlock = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_loanType == LoanTypeNSD) {
        self.themeColor = kNSDThemeColor;
    } else if (_loanType == LoanTypeCED) {
        self.themeColor = kCEDThemeColor;
    } else if (_loanType == LoanTypeNewQD || _loanType == LoanTypeNewJSD) {
        self.themeColor = kwhiteColor;
    } else {
        self.themeColor = kThemeColor;
    }
    if (CGColorEqualToColor(self.themeColor.CGColor, kwhiteColor.CGColor)) {
        [self initLeftItemWithName:@"" withImage:@"back_black"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (CGColorEqualToColor(self.themeColor.CGColor, kwhiteColor.CGColor)) {
        [self configNavBarWithFont:FONT(18) foregroundColor:UIColorFromRGB(0x333333) bgColor:self.themeColor];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setShadowImage:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

#pragma mark -- private methods

- (void)nextStepWithData:(id)data
{
    //回调不为空时，走回调
    if (_completedBlock) {
        _completedBlock(YES,data);
    }
}


- (NSString *)getCompleteH5UrlWithDictionary:(NSDictionary *)dict metaUrl:(NSString *)metaUrl
{
    // 拼接参数
    NSMutableString *paramString = @"".mutableCopy;
    if (DictionaryIsNullOrEmpty(dict)) {
        return paramString;
    }
    NSArray *allKeys = [dict allKeys];
    for (int i = 0; i < allKeys.count; i++) {
        NSString *key = [allKeys objectAtIndex:i];
        NSString *value = [dict valueForKey:key];
        if (!StringIsNullOrEmpty(key) && !StringIsNullOrEmpty(value)) {
            NSString *tmpString = [NSString stringWithFormat:@"%@=%@&", key, value];
            [paramString appendString:tmpString];
        }
    }
    [paramString deleteCharactersInRange:NSMakeRange((paramString.length -1), 1)];
    
    // 拼接完整URL
    NSString *completeH5Url = @"";
    if ([metaUrl hasPrefix:@"http://"] || [metaUrl hasPrefix:@"https://"]) {
        completeH5Url = [NSString stringWithFormat:@"%@?%@", metaUrl, paramString];
    } else {
        completeH5Url = [NSString stringWithFormat:@"%@%@?%@",[HYDNetWorkMacro getUrlHostWithServiceType:ServiceTypeJsd], metaUrl, paramString];
    }
    
    return completeH5Url;
}

@end
