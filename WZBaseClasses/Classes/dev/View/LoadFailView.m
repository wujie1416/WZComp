//
//  LoadFailView.m
//  HC-HYD
//
//  Created by 罗志超 on 2017/5/19.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "LoadFailView.h"
#import "Masonry.h"
#import "UtilsMacro.h"
#import "UIImage+WZ.h"
#import "WZBaseCLassMacro.h"


@interface LoadFailView()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UIButton *refreshBtn;
@property (strong, nonatomic) UIButton *applyNowButton;

@property (nonatomic, copy)  void(^reFreshBtnClick)(void);
@end

@implementation LoadFailView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
}

- (void)showWithType:(LoadFailType)type reFreshBlock:(void(^)(void))block
{
    UIImage *image = nil;
    if (type == LoadRefreshFail) {
        image =[UIImage wz_imageWithName:@"pic_loadfailure" bundle:kWZBaseCLassBundleName];
        self.textLabel.text = @"加载失败";
    }else if (type == LoadNoData){
        image =[UIImage wz_imageWithName:@"pic_loadfailure" bundle:kWZBaseCLassBundleName];
        self.textLabel.text = @"还没有申请记录";
    } else if (type == LoadNetFail){
        image =[UIImage wz_imageWithName:@"pic_nonetwork" bundle:kWZBaseCLassBundleName];
        self.textLabel.text = @"网络连接失败";
    }
    
    [self.imageView setImage:image];
    
    CGFloat imgRate = iPhone4or5 ? 1.0 : 1.3;
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).offset(type == LoadRefreshFail?150:100);
        make.size.mas_equalTo(CGSizeMake(image.size.width*imgRate, image.size.height*imgRate));
    }];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.imageView.mas_bottom).offset(30);
        make.left.right.equalTo(self);
        make.height.mas_offset(22);
    }];
    
    CGFloat btnRate = iPhone4or5||iPhone6P ? 1.0 : 1.2;
    
    [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.textLabel.mas_bottom).mas_offset(30);
        make.size.mas_equalTo(CGSizeMake(92*btnRate, 35*btnRate));
    }];

    [self.applyNowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.textLabel.mas_bottom).mas_offset(30);
        make.size.mas_equalTo(CGSizeMake(ALD(240), 44));
    }];
    
    if (type == LoadNoData) {
        self.refreshBtn.hidden = YES;
        self.applyNowButton.hidden = NO;
    }else{
        self.refreshBtn.hidden = NO;
        self.applyNowButton.hidden = YES;
    }
    
    _reFreshBtnClick = block;
}

#pragma mark -- event

- (void)onClickRefreshBtn
{
    [self removeFromSuperview];
    if (_reFreshBtnClick) {
        _reFreshBtnClick();
    }
}
#pragma mark -- getter

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.text = @"网络连接失败";
        _textLabel.textColor = UIColorFromRGB(0x444444);
        _textLabel.font = [UIFont systemFontOfSize:20];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
        
    }
    return _textLabel;
}

-(UIButton *)applyNowButton
{
    if (!_applyNowButton) {
        _applyNowButton = [[UIButton alloc] init];
        [_applyNowButton setBackgroundColor:RGBA(27,108,250,1.0f)];
        [_applyNowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_applyNowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_applyNowButton setTitle:@"立即申请" forState:UIControlStateNormal];
        _applyNowButton.layer.masksToBounds = YES;
        _applyNowButton.layer.cornerRadius = 22;
        [_applyNowButton addTarget:self action:@selector(onClickRefreshBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_applyNowButton];
    }
    return _applyNowButton;
    
}

- (UIButton *)refreshBtn
{
    if (!_refreshBtn) {
        _refreshBtn = [[UIButton alloc] init];
        UIImage *image =[UIImage wz_imageWithName:@"btn_refresh" bundle:kWZBaseCLassBundleName];
        [_refreshBtn setBackgroundImage:image forState:UIControlStateNormal];
        [_refreshBtn addTarget:self action:@selector(onClickRefreshBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_refreshBtn];
    }
    return _refreshBtn;
}

@end
