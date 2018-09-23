//
//  HYDCompBaseController.m
//  HC-HYD
//
//  Created by wl on 2017/12/4.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "HYDCompBaseController.h"

@implementation HYDCompBaseController

- (id)initWithLoanType:(LoanType)loanType loanId:(NSString *)loanId unitCode:(NSString *)unitCode completedBlock:(void(^)(BOOL result, id data))block
{
    return [self initWithLoanType:loanType loanId:loanId flowId:@"" unitCode:unitCode completedBlock:block];
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
    [self configNavBarBGColor:self.themeColor];
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

- (void)nextStepWithData:(id)data
{
    //回调不为空时，走回调
    if (_completedBlock) {
        _completedBlock(YES,data);
    }
}

@end
