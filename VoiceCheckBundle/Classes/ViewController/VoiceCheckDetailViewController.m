//
//  VoiceCheckDetailViewController.m
//  AFNetworking
//
//  Created by wujie on 2018/5/17.
//

#import "VoiceCheckDetailViewController.h"
#import "UtilsMacro.h"
#import "BusMacro.h"
#import "AddVoiceView.h"
#import "VoiceTableViewCell.h"
#import "Masonry.h"
#import "RecorderViewController.h"
#import "UIImage+VoiceCheck.h"
#import "VoiceCheckGetVoiceStatusManager.h"
#import "MBProgressHUD+WZ.h"
static NSString *cellIdentifier = @"Listcell";
@interface VoiceCheckDetailViewController () <UITableViewDelegate,UITableViewDataSource,HYDBaseRequestManagerCallBackDelegate>
@property (nonatomic, strong) AddVoiceView *addVoiceView;
@property (nonatomic, strong) UILabel *label;
//@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) VoiceCheckGetVoiceStatusManager *getVoiceStatusManager;
@property (nonatomic, assign) BOOL firstInitTableView;
@end

@implementation VoiceCheckDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"声纹采集";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configNavBarWithFont:kFont(17) foregroundColor:UIColorFromRGB(0x333333) bgColor:UIColorFromRGB(0xFFFFFF)];
    [self initLeftItemWithName:@"" withImage:@"back_black"];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.getVoiceStatusManager startTask];
}

- (void)initAddVoiceView
{
    WS(weakSelf);
    [self.view addSubview:self.addVoiceView];
    self.addVoiceView.btnClickBlock = ^{
        RecorderViewController *vc = [[RecorderViewController alloc] init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
}

- (void)initMjTableView
{
    [self.mjTableView registerClass:[VoiceTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:self.mjTableView];
    [self.mjTableView addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(75);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(200);
    }];
//    [self.view addSubview:self.button];
//    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(-30);
//        make.centerX.equalTo(self.view.mas_centerX);
//        make.size.mas_equalTo(CGSizeMake(280, 43));
//    }];
    [self setMJTableHasHeader:YES hasFooter:NO];
}

- (void)manager:(HYDBaseRequestManager *)manager didSuccessWithResponse:(APIURLResponse *)response
{
    if (manager == self.getVoiceStatusManager) {
        if ([self.getVoiceStatusManager.valid isEqualToString:@"3"]) {//没有声纹采集信息
            [self initAddVoiceView];
        } else { //有声纹采集信息
            if (!self.firstInitTableView) {
                [self initMjTableView];
                self.firstInitTableView = YES;
            }
            self.label.text = self.getVoiceStatusManager.describ;
            [self.mjTableView reloadData];
            [self endMJRefreshAnimation];
        }
    }
}

- (void)manager:(HYDBaseRequestManager *)manager didFailedWithError:(NSError *)error
{
    [self endMJRefreshAnimation];
    [MBProgressHUD showMessage:manager.retModel.showMsg];
}

- (void)mjRefreshHeader
{
    [self.getVoiceStatusManager startTask];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([self.getVoiceStatusManager.valid isEqualToString:@"0"]) {
        cell.dataLabel.text = self.getVoiceStatusManager.ymdStr;
        cell.timeLabel.text = self.getVoiceStatusManager.hmsStr;
        [cell.statusButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        [cell.statusButton setTitle:@"声纹检测中" forState:UIControlStateNormal];
    } else if ([self.getVoiceStatusManager.valid isEqualToString:@"1"]) {
        cell.dataLabel.text = self.getVoiceStatusManager.ymdStr;
        cell.timeLabel.text = self.getVoiceStatusManager.hmsStr;
        [cell.statusButton setTitleColor:UIColorFromRGB(0x10A8EA) forState:UIControlStateNormal];
        [cell.statusButton setTitle:@"审核通过" forState:UIControlStateNormal];
    } else if ([self.getVoiceStatusManager.valid isEqualToString:@"2"]) {
        cell.dataLabel.text = self.getVoiceStatusManager.ymdStr;
        cell.timeLabel.text = self.getVoiceStatusManager.hmsStr;
        [cell.statusButton setTitleColor:UIColorFromRGB(0xF88D33) forState:UIControlStateNormal];
        [cell.statusButton setTitle:@"不合格,点击重录" forState:UIControlStateNormal];
        cell.btnClickBlock = ^{
            RecorderViewController *vc = [[RecorderViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        };
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

//- (void)btnClick
//{
//    RecorderViewController *vc = [[RecorderViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
//}

- (AddVoiceView *)addVoiceView
{
    if (!_addVoiceView) {
        _addVoiceView = [[AddVoiceView alloc] initWithFrame:self.view.frame];
    }
    return _addVoiceView;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = UIColorFromRGB(0x999999);
        _label.font = kFont(12);
    }
    return _label;
}

//- (UIButton *)button
//{
//    if (!_button) {
//        _button = [UIButton buttonWithType:UIButtonTypeSystem];
//        [_button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
//        [_button setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
//        [_button setBackgroundColor:UIColorFromRGB(0x10A8EA)];
//        [_button setTitle:@"添加声纹" forState:UIControlStateNormal];
//        _button.layer.cornerRadius = 21.5;
//        _button.layer.masksToBounds = YES;
//        _button.titleLabel.font = kFont(16);
//    }
//    return _button;
//}

- (VoiceCheckGetVoiceStatusManager *)getVoiceStatusManager
{
    if (!_getVoiceStatusManager) {
        _getVoiceStatusManager = [[VoiceCheckGetVoiceStatusManager alloc] initWithCallBackDelegate:self];
    }
    return _getVoiceStatusManager;
}

@end
