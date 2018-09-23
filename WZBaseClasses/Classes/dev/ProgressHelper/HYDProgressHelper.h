//
//  HYDProgressHelper.h
//  HC-HYD
//
//  Created by wangling on 2018/3/29.
//  Copyright © 2018年 cheyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYDNavigationController.h"
#import "HYDBaseRequestManager.h"

@protocol HYDProgressManagerProtocol <NSObject>
- (void)startTaskWithLoanId:(NSString *)loanId;
@end


@interface HYDProgressHelper : NSObject <HYDBaseRequestManagerCallBackDelegate>
@property (nonatomic, strong) NSString *loanId;
@property (nonatomic, assign) NSInteger popNum;
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, copy) void(^progressEndBlock)(NSString *loanId);
@property (nonatomic, weak, readonly) HYDNavigationController *naviController;

@property (nonatomic, strong) HYDBaseRequestManager<HYDProgressManagerProtocol> *progressManager;

- (instancetype)initWithLoanId:(NSString *)loanId controller:(UIViewController *)controller popNum:(NSInteger)popNum;

- (void)resetWithLoanId:(NSString *)loanId controller:(UIViewController *)controller popNum:(NSInteger)popNum progressEnd:(void (^)(NSString *loanId))block;
/*
 检查并开始后续流程
 */
- (void)checkProgress;

@end
