//
//  HYDProgressHelper.m
//  HC-HYD
//
//  Created by wangling on 2018/3/29.
//  Copyright © 2018年 cheyy. All rights reserved.
//

#import "HYDProgressHelper.h"
#import "MBProgressHUD+WZ.h"

@implementation HYDProgressHelper

- (instancetype)initWithLoanId:(NSString *)loanId controller:(UIViewController *)controller popNum:(NSInteger)popNum
{
    if (self = [super init]) {
        [self resetWithLoanId:loanId controller:controller popNum:popNum progressEnd:nil];
    }
    return self;
}

- (void)resetWithLoanId:(NSString *)loanId controller:(UIViewController *)controller popNum:(NSInteger)popNum progressEnd:(void (^)(NSString *loanId))block
{
    _loanId = loanId;
    _popNum = popNum;
    _controller = controller;
    _progressEndBlock = block;
    if ([controller.rt_navigationController isKindOfClass:[HYDNavigationController class]]) {
        _naviController = (HYDNavigationController *)controller.rt_navigationController;
    }
}

- (void)checkProgress
{
    [self.progressManager startTaskWithLoanId:_loanId];
}


#pragma mark - HYDBaseRequestManagerCallBackDelegate
- (void)manager:(HYDBaseRequestManager *)manager didSuccessWithResponse:(APIURLResponse *)response
{
    if (manager == self.progressManager) {
        [self dealProgress];
    }
}

- (void)manager:(HYDBaseRequestManager *)manager didFailedWithError:(NSError *)error
{
    [MBProgressHUD showMessage:manager.retModel.showMsg];
}

- (void)dealProgress
{
    //sub class to override
}

- (HYDBaseRequestManager<HYDProgressManagerProtocol> *)progressManager
{
    //sub class to override
    return nil;
}

@end
