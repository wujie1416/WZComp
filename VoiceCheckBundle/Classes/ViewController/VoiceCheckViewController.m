//
//  HYDVoiceCheckViewController.m
//  WZBaseClasses-WZBaseClasses
//
//  Created by wujie on 2018/5/17.
//

#import "VoiceCheckViewController.h"
#import "UtilsMacro.h"
#import "BusMacro.h"
#import "Masonry.h"
#import "VoiceCheckDetailViewController.h"
#import "VoiceCheckGetUserNotesManager.h"
#import "MBProgressHUD+WZ.h"
#import "VoiceCheckInsertUserAuthStatusManager.h"

@interface VoiceCheckViewController () <HYDBaseRequestManagerCallBackDelegate>

@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIWebView *WebView;
@property (nonatomic, strong) VoiceCheckGetUserNotesManager *getUserNotesManager;
@property (nonatomic, strong) VoiceCheckInsertUserAuthStatusManager *insertUserAuthStatusManager;
@end

@implementation VoiceCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"声纹采集";
    [self initSubViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configNavBarWithFont:kFont(17) foregroundColor:UIColorFromRGB(0x333333) bgColor:UIColorFromRGB(0xFFFFFF)];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self initLeftItemWithName:@"" withImage:@"back_black"];
    [self.getUserNotesManager startTask];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubViews
{
    if (iPhoneX) {
        [self.view addSubview:self.WebView];
        [self.WebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(84, 0, 0, 0));
        }];
    } else {
        [self.view addSubview:self.WebView];
        [self.WebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(64, 0, 0, 0));
        }];
    }
    [self.view addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.height.equalTo(@(49));
        make.bottom.offset(0);
        
    }];
    [self.view addSubview:self.confirmBtn];
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(0);
        make.bottom.offset(0);
        make.height.equalTo(@(49));
        make.width.equalTo(self.cancelBtn.mas_width);
        make.left.equalTo(self.cancelBtn.mas_right).with.offset(0);
    }];
}

- (void)manager:(HYDBaseRequestManager *)manager didSuccessWithResponse:(APIURLResponse *)response
{
    if (manager == self.getUserNotesManager) {
        [self.WebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.getUserNotesManager.h5Url]]];
    } else if (manager == self.insertUserAuthStatusManager) {
        if (self.insertUserAuthStatusManager.status == 1) {
            VoiceCheckDetailViewController *vc = [[VoiceCheckDetailViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)manager:(HYDBaseRequestManager *)manager didFailedWithError:(NSError *)error
{
    [MBProgressHUD showMessage:manager.retModel.showMsg];
}

- (void)cancelBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmBtnClick
{
    [self.insertUserAuthStatusManager startTask];
}

- (UIButton *)confirmBtn
{
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_confirmBtn setTitle:@"同意授权" forState:UIControlStateNormal];
        [_confirmBtn setBackgroundColor:UIColorFromRGB(0x10A8EA)];
        [_confirmBtn setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = kFont(17);
        [_confirmBtn addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelBtn setTitle:@"不同意授权" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        [_cancelBtn setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        _cancelBtn.titleLabel.font = kFont(17);
        [_cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIWebView *)WebView
{
    if (!_WebView) {
        _WebView = [[UIWebView alloc] init];
    }
    return _WebView;
}

- (VoiceCheckGetUserNotesManager *)getUserNotesManager
{
    if (!_getUserNotesManager) {
        _getUserNotesManager = [[VoiceCheckGetUserNotesManager alloc] initWithCallBackDelegate:self];
    }
    return _getUserNotesManager;
}

- (VoiceCheckInsertUserAuthStatusManager *)insertUserAuthStatusManager
{
    if (!_insertUserAuthStatusManager) {
        _insertUserAuthStatusManager = [[VoiceCheckInsertUserAuthStatusManager alloc] initWithCallBackDelegate:self];
    }
    return _insertUserAuthStatusManager;
}

@end
