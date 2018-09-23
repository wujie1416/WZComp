//
//  HYDViewController.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/27.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "TPKeyboardAvoidingTableView.h"
#import "FORScrollViewEmptyAssistant.h"
#import "LoadFailView.h"

#define HYDHomeNaviController ((HYDNavigationController *)[((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabbarC.viewControllers objectAtIndex:0])
#define HYDServerNaviController ((HYDNavigationController *)[((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabbarC.viewControllers objectAtIndex:1])
#define HYDMyNaviController ((HYDNavigationController *)[((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabbarC.viewControllers objectAtIndex:2])

@interface HYDViewController : UIViewController
@property (nonatomic, strong) UITableView *mjTableView;//可设置上拉下拉加载动画
@property (nonatomic, strong) UITableView *groupTableView;
@property (nonatomic, strong) TPKeyboardAvoidingTableView *tpTableView;
@property (nonatomic, strong) TPKeyboardAvoidingScrollView *tpScrollView;
@property (nonatomic, strong) FOREmptyAssistantConfiger *configer;

/**
 *  主题色
 */
@property (nonatomic, copy) UIColor *themeColor;

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
 *  在导航透明时设置背景
 */
- (void)initNavigationBarView;

/**
 *  设置控制器title颜色
 */
- (void)setTitleTextColor:(UIColor *)color;

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
 *  显示加载失败的View
 */
- (void)showFailViewWithType:(LoadFailType)type reFreshBlock:(void(^)(void))block;

/**
 *  隐藏加载失败的View
 */
- (void)hideFailView;

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

/**
 设置随手指拖动，导航栏颜色的渐变
 @param scrollView 滑动的view
 @param sColor 起始颜色
 @param eColor 终点颜色
 */
- (void)setNaviBarChangeColorWithScrollView:(UIScrollView *)scrollView startColor:(UIColor *)sColor endColor:(UIColor *)eColor;
@end
