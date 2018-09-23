//
//  HYDNavigationController.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/27.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTRootNavigationController.h"

@interface HYDNavigationController : RTRootNavigationController

/**
 push到下一页面并销毁当前页面

 @param viewController 要push的viewController
 @param animated 动画
 */
- (void)pushViewControllerWithDestorySelfVc:(UIViewController *)viewController animated:(BOOL)animated;


/**
 push到下一面，并销毁原来栈顶的VC
 
 @param viewController 要push的viewController
 @param num 要销毁的栈顶的viewController数量
 @param animated 动画
 */
- (void)pushViewController:(UIViewController *)viewController destoryStackTopVcs:(NSInteger) num  animated:(BOOL)animated;

@end
