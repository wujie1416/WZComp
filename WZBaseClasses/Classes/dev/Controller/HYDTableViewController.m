//
//  HYDTableViewController.m
//  HC-HYD
//
//  Created by 罗志超 on 2017/4/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "HYDTableViewController.h"
#import "HYDRefreshFooter.h"
#import "HYDRefreshHeader.h"
#import <WZLogger/WZLogging.h>
#import "UtilsMacro.h"
#import "BusMacro.h"
#import "HYDNavigationController.h"
#import "UIImage+WZ.h"
#import "WZBaseCLassMacro.h"

@interface HYDTableViewController ()

@end

@implementation HYDTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:kBackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initLeftItemWithName:nil withImage:@"return"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self restoreNavBarColor];
}

- (void)dealloc {
     WZLogDebug(@"%@ %@!!!", [self class], NSStringFromSelector(_cmd));
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

    //创建左导航键
- (void)initLeftItemWithName:(NSString *)title withImage:(NSString *)imageName
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:imageName];
    if (img == nil) {
        NSString *imgPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:[NSString stringWithFormat:@"/WZBaseClasses.bundle/%@.png", imageName]];
        img = [UIImage imageWithContentsOfFile:imgPath];
    }
    [btn setImage:img forState:UIControlStateNormal];
    btn.imageEdgeInsets  = UIEdgeInsetsMake(0, -20, 0, 6);
    [btn addTarget:self action:@selector(clickedLeftNavItem:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0,40, 44);
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    leftItem.target = self;
    self.navigationItem.leftBarButtonItem = leftItem;
}

    //创建右导航键
- (void)initRightItemWithName:(NSString *)title withImage:(NSString *)imageName
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:RGBA(255, 255, 255, 1) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    if (imageName && imageName.length>0) {
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        btn.imageEdgeInsets  = UIEdgeInsetsMake(0, -6, 0, 6);
        btn.frame = CGRectMake(0, 0,btn.currentImage.size.width, btn.currentImage.size.height);
    } else {
        btn.frame = CGRectMake(0, 0, 44, 30);
    }
    [btn addTarget:self action:@selector(clickedRightNavItem:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    rightItem.target = self;
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark -- utilPrivateFunc

- (void)popToAppRootShow
{
    for (int i = 0; i < [(UITabBarController *)[[UIApplication sharedApplication] delegate].window.rootViewController viewControllers].count; i++) {
        HYDNavigationController* nav = [[(UITabBarController *)[[UIApplication sharedApplication] delegate].window.rootViewController viewControllers] objectAtIndex:i];
        if (nav.presentedViewController) {
            [nav dismissViewControllerAnimated:NO completion:nil];
        }
        [nav popToRootViewControllerAnimated:NO];
    }
}

/**
 * 下拉刷新加载的函数（可由子类重载）
 */
- (void)mjRefreshHeader
{
    
}
/**
 * 上拉刷新加载的函数（可由子类重载）
 */
- (void)mjRefreshFooter
{
    
}

#pragma mark
#pragma mark - getter &  setter
- (TPKeyboardAvoidingTableView *)tpTableView {
    if (!_tpTableView) {
        _tpTableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectZero];
        _tpTableView.backgroundColor = kBackColor;
        _tpTableView.delegate = self;
        _tpTableView.dataSource = self;
        _tpTableView.showsHorizontalScrollIndicator = NO;
        _tpTableView.showsVerticalScrollIndicator = NO;
    }
    return _tpTableView;
}

- (TPKeyboardAvoidingScrollView *)tpScrollView {
    if (!_tpScrollView) {
        _tpScrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _tpScrollView.showsVerticalScrollIndicator = NO;
        _tpScrollView.backgroundColor = kBackColor;
        [_tpScrollView setContentSize:CGSizeMake(_tpScrollView.frame.size.width, _tpScrollView.frame.size.height)];
        _tpScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _tpScrollView;
}

#pragma mark
#pragma mark - 页面工具函数
- (void)setNavBarTransparent{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)restoreNavBarColor
{
    [self configNavBarWithFont:kHYD20Font foregroundColor:kBackColor bgColor:kThemeColor];
}

- (void)configNavBarBGColor:(UIColor *)bgColor
{
    [self configNavBarWithFont:kHYD20Font foregroundColor:kBackColor bgColor:bgColor];
}

- (void)configNavBarWithFont:(UIFont *)font foregroundColor:(UIColor *)fColor bgColor:(UIColor *)bgColor
{
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:fColor}];
    CGSize size = CGSizeMake(1, 1);
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}
#pragma mark
#pragma mark - 用户交互
//点击左导航键-(可重载)
- (void)clickedLeftNavItem:(UIBarButtonItem *)leftItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickedRightNavItem:(UIBarButtonItem *)rightItem
{
    WZLogInfo(@"点击了导航栏右侧按钮");
}

#pragma mark - 返回首页
- (void)goHome
{
    [self popToAppRootShow];
    [(UITabBarController *)[[UIApplication sharedApplication] delegate].window.rootViewController setSelectedIndex:0];
}

#pragma mark - 返回服务
- (void)goServe
{
    [self popToAppRootShow];
    [(UITabBarController *)[[UIApplication sharedApplication] delegate].window.rootViewController setSelectedIndex:1];
}

#pragma mark - 返回我的
- (void)goProfile
{
    [self popToAppRootShow];
    [(UITabBarController *)[[UIApplication sharedApplication] delegate].window.rootViewController setSelectedIndex:2];
}

- (void)setMJTableHasHeader:(BOOL)h hasFooter:(BOOL)f
{
    if (h) {
        self.tableView.mj_header = [HYDRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(mjRefreshHeader)];
    }
    if (f) {
        self.tableView.mj_footer = [HYDRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(mjRefreshFooter)];
    }
}

- (void)endMJRefreshAnimation
{
    if (self.tableView.mj_header) {
        [self.tableView.mj_header endRefreshing];
    }
    if (self.tableView.mj_footer) {
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)beginMJHeaderRefresh
{
    if (self.tableView.mj_header) {
        [self.tableView.mj_header beginRefreshing];
    }
}

- (void)beginMJFooterRefresh
{
    if (self.tableView.mj_footer) {
        [self.tableView.mj_footer beginRefreshing];
    }
}

- (void)pushViewControllerWithDestorySelfVc:(UIViewController *)viewController
{
    [(HYDNavigationController *)self.navigationController pushViewControllerWithDestorySelfVc:viewController animated:YES];
}

- (void)pushViewController:(UIViewController *)viewController destoryStackTopNum:(NSInteger ) number
{
    [(HYDNavigationController *)self.navigationController pushViewController:viewController destoryStackTopVcs:number animated:YES];
}
@end
