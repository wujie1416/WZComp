//
//  HYDNavigationController.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/27.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "HYDNavigationController.h"
@interface HYDNavigationController ()

@end

@implementation HYDNavigationController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark
#pragma mark - 2.View代理、数据源方法

#pragma mark 系统代理
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    if ([self getPushStateWithViewController:viewController]) {
        viewController.rt_disableInteractivePop = NO;
        [super pushViewController:viewController animated:animated];
    }
}

- (void)pushViewControllerWithDestorySelfVc:(UIViewController *)viewController animated:(BOOL)animated
{
    [self pushViewController:viewController destoryStackTopVcs:1 animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController destoryStackTopVcs:(NSInteger) num  animated:(BOOL)animated
{
    [self pushViewController:viewController animated:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *viewControllers = [[NSMutableArray alloc]initWithArray:self.viewControllers];
        if (num >= viewControllers.count-1 || num < 0) {
            viewControllers = [NSMutableArray arrayWithObjects:viewControllers[0], viewControllers.lastObject ,nil];
        } else {
            for (int i=0; i<num; i++) {
                [viewControllers removeObjectAtIndex:viewControllers.count-2];
            }
        }
        self.viewControllers = viewControllers;
    });
}

- (BOOL)getPushStateWithViewController:(UIViewController *)viewController
{
    NSArray *vcArr = self.rt_viewControllers;
    if (vcArr.count > 0) {
        NSString *newVC = [NSString stringWithUTF8String:object_getClassName(viewController)];
        NSString *currentVC = [NSString stringWithUTF8String:object_getClassName([vcArr lastObject])];
        if ([newVC isEqualToString:currentVC]) {
            return NO;
        } else {
            return YES;
        }
    }
    return YES;
}


@end
