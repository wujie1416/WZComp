//
//  HYDTableViewController.h
//  HC-HYD
//
//  Created by 罗志超 on 2017/4/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingTableView.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface HYDTableViewController : UITableViewController

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tpTableView;
@property (nonatomic, strong) TPKeyboardAvoidingScrollView *tpScrollView;

/**
 *  设置导航栏透明
 */
-(void)setNavBarTransparent;

/**
 *  恢复导航栏的原有主题颜色
 */
- (void)restoreNavBarColor;

/**
 *  配置导航栏背景色
 */
- (void)configNavBarBGColor:(UIColor *)bgColor;

/**
 *  配置导航栏 字体、颜色、背景
 */
- (void)configNavBarWithFont:(UIFont *)font foregroundColor:(UIColor *)fColor bgColor:(UIColor *)bgColor;

/**
 *  创建导航栏左侧的按钮
 */
- (void)initLeftItemWithName:(NSString *)title withImage:(NSString *)imageName;

/**
 *  创建导航栏右侧的按钮
 */
- (void)initRightItemWithName:(NSString *)title withImage:(NSString *)imageName;

/**
 *  返回首页
 */
-(void)goHome;

/**
 *  返回服务首页
 */
- (void)goServe;

/**
 *  返回我的首页
 */
- (void)goProfile;

/**
 *  设置刷新是否有刷新头和刷新尾，默认都没有
 */
- (void)setMJTableHasHeader:(BOOL)h hasFooter:(BOOL)f;

/**
 *  停止mjHeader和Footer的刷新动画
 */
- (void)endMJRefreshAnimation;

/**
 *  手动启动mjHeader刷新功能
 */
- (void)beginMJHeaderRefresh;

/**
 *  手动启动mjFooter刷新功能
 */
- (void)beginMJFooterRefresh;

/**
 push下一页删除这一页
 @param viewController 下一页
 */
- (void)pushViewControllerWithDestorySelfVc:(UIViewController *)viewController;

/**
 push下一页删除原栈顶vc
 @param viewController 下一页
 @param number 销毁数量
 */
- (void)pushViewController:(UIViewController *)viewController destoryStackTopNum:(NSInteger ) number;
@end

