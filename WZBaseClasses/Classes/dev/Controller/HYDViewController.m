//
//  HYDViewController.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/27.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "HYDViewController.h"
#import "HYDRefreshFooter.h"
#import "HYDRefreshHeader.h"
#import "HYDNavigationController.h"
#import <WZLogger/WZLogging.h>
#import "UtilsMacro.h"
#import "BusMacro.h"
#import "Masonry.h"
#import "UIImage+WZ.h"
#import "WZBaseCLassMacro.h"
#import <mach/mach.h>

@interface HYDViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (nonatomic, strong) LoadFailView *loadFailView;

@end

@implementation HYDViewController
{
    UIScrollView *_scrollView;
    UIColor *_naviStartColor;
    UIColor *_naviEndColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _themeColor = kThemeColor;
    [self.view setBackgroundColor:RGBA(245, 245, 245, 1)];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self initLeftItemWithName:nil withImage:@"return"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self restoreNavBarColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    mach_task_basic_info_data_t taskInfo;
    unsigned infoCount = sizeof(taskInfo);
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         MACH_TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    double memoryUsage = 0;
    if (kernReturn != KERN_SUCCESS ) {
        memoryUsage = 0;
    }
    memoryUsage = taskInfo.resident_size / 1024.0 / 1024.0;
    WZLogWarning(@"<---------------> %@ %@!!! and memoryUsage:%.2f(MB)", [self class], NSStringFromSelector(_cmd), memoryUsage);
}

- (void)dealloc
{
     WZLogDebug(@"<---------------> %@ %@!!!", [self class], NSStringFromSelector(_cmd));
}

#pragma mark
#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_scrollView == scrollView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        UIColor *color = [UIColor colorWithRed:_naviEndColor.CIColor.red green:_naviEndColor.CIColor.green blue:_naviEndColor.CIColor.blue alpha:offsetY>100 ? 1 : (offsetY / 100)];
        CGSize size = CGSizeMake(1, 1);
        CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
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
//在导航透明时设置背景
- (void)initNavigationBarView
{
    UINavigationBar * navigationBar = [[UINavigationBar alloc] init];
    navigationBar.barTintColor = RGBA(27,108,250,1.0f);
    [self.view addSubview:navigationBar];
    
    WS(ws);
    [navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws.view).offset(0);
        make.left.right.equalTo(ws.view);
        make.height.mas_equalTo(@64);
    }];
}

- (void)setTitleTextColor:(UIColor *)color
{
    if (color) {
        [self.navigationController.navigationBar setTitleTextAttributes:
         @{NSFontAttributeName:[UIFont systemFontOfSize:20],
           NSForegroundColorAttributeName:color}];
    } else {
        [self.navigationController.navigationBar setTitleTextAttributes:
         @{NSFontAttributeName:[UIFont systemFontOfSize:20],
           NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
    
}

- (void)popToAppRootShow
{
    for (int i = 0; i < [(UITabBarController *)[[UIApplication sharedApplication] delegate].window.rootViewController viewControllers].count; i++) {
        HYDNavigationController* nav = [[(UITabBarController *)[[UIApplication sharedApplication] delegate].window.rootViewController viewControllers] objectAtIndex:i];
        if (nav.presentedViewController && ![nav.rt_visibleViewController isKindOfClass:NSClassFromString(@"HYDLoginViewController")]) {
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

- (UITableView *)mjTableView
{
    if (!_mjTableView) {
        _mjTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mjTableView.backgroundColor = kBackColor;
        _mjTableView.delegate = self;
        _mjTableView.dataSource = self;
        _mjTableView.estimatedRowHeight = 0;
        _mjTableView.estimatedSectionFooterHeight = 0;
        _mjTableView.estimatedSectionHeaderHeight = 0;
        _mjTableView.showsHorizontalScrollIndicator = NO;
        _mjTableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_mjTableView];
    }
    return _mjTableView;
}

- (UITableView *)groupTableView
{
    if(!_groupTableView){
        _groupTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _groupTableView.backgroundColor = kBackColor;
        _groupTableView.delegate = self;
        _groupTableView.dataSource = self;
        _groupTableView.estimatedRowHeight = 0;
        _groupTableView.estimatedSectionFooterHeight = 0;
        _groupTableView.estimatedSectionHeaderHeight = 0;
        _groupTableView.showsHorizontalScrollIndicator = NO;
        _groupTableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_groupTableView];
    }
    return _groupTableView;
}

- (TPKeyboardAvoidingTableView *)tpTableView
{
    if (!_tpTableView) {
        _tpTableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectZero];
        _tpTableView.backgroundColor = kBackColor;
        _tpTableView.delegate = self;
        _tpTableView.dataSource = self;
        _tpTableView.estimatedRowHeight = 0;
        _tpTableView.estimatedSectionFooterHeight = 0;
        _tpTableView.estimatedSectionHeaderHeight = 0;
        _tpTableView.showsHorizontalScrollIndicator = NO;
        _tpTableView.showsVerticalScrollIndicator = NO;
    }
    return _tpTableView;
}

-(TPKeyboardAvoidingScrollView *)tpScrollView
{
    if (!_tpScrollView) {
        _tpScrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _tpScrollView.showsVerticalScrollIndicator = NO;
        _tpScrollView.backgroundColor = kBackColor;
        [_tpScrollView setContentSize:CGSizeMake(_tpScrollView.frame.size.width, _tpScrollView.frame.size.height)];
        _tpScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _tpScrollView;
}

- (LoadFailView *)loadFailView
{
    if (!_loadFailView) {
        _loadFailView = [[LoadFailView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_loadFailView];
    }
    return _loadFailView;
}

#pragma mark
#pragma mark - 页面工具函数
- (void)setNavBarTransparent
{
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
    
    if (CGColorEqualToColor(bgColor.CGColor, kwhiteColor.CGColor)) {
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
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
    WZLogDebug(@"点击了导航栏右侧按钮");
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
        self.mjTableView.mj_header = [HYDRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(mjRefreshHeader)];
    }
    if (f) {
        self.mjTableView.mj_footer = [HYDRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(mjRefreshFooter)];
    }
}

- (void)endMJRefreshAnimation
{
    if (self.mjTableView.mj_header) {
        [self.mjTableView.mj_header endRefreshing];
    }
    if (self.mjTableView.mj_footer) {
        [self.mjTableView.mj_footer endRefreshing];
    }
}

- (void)beginMJHeaderRefresh
{
    if (self.mjTableView.mj_header) {
        [self.mjTableView.mj_header beginRefreshing];
    }
}

- (void)beginMJFooterRefresh
{
    if (self.mjTableView.mj_footer) {
        [self.mjTableView.mj_footer beginRefreshing];
    }
}

- (void)showFailViewWithType:(LoadFailType)type reFreshBlock:(void(^)(void))block
{
    [self.view addSubview:self.loadFailView];
    [self.loadFailView showWithType:type reFreshBlock:block];
}

- (void)hideFailView
{
    [self.loadFailView removeFromSuperview];
    _loadFailView = nil;
}

- (void)pushViewControllerWithDestorySelfVc:(UIViewController *)viewController
{
    [(HYDNavigationController *)self.navigationController pushViewControllerWithDestorySelfVc:viewController animated:YES];
}

- (void)pushViewController:(UIViewController *)viewController destoryStackTopNum:(NSInteger ) number
{
    [(HYDNavigationController *)self.navigationController pushViewController:viewController destoryStackTopVcs:number animated:YES];
}

- (void)setNaviBarChangeColorWithScrollView:(UIScrollView *)scrollView startColor:(UIColor *)sColor endColor:(UIColor *)eColor
{
    _naviStartColor = sColor;
    _naviEndColor = eColor;
    _scrollView = scrollView;
    _scrollView.delegate = self;
    UIColor *color = [UIColor colorWithRed:_naviEndColor.CIColor.red green:_naviEndColor.CIColor.green blue:_naviEndColor.CIColor.blue alpha:0];
    CGSize size = CGSizeMake(1, 1);
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

@end
