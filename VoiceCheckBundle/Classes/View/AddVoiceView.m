//
//  AddVoiceView.m
//  AFNetworking
//
//  Created by wujie on 2018/5/17.
//

#import "AddVoiceView.h"
#import "Masonry.h"
#import "UtilsMacro.h"
#import "BusMacro.h"
#import "UIImage+VoiceCheck.h"

@interface AddVoiceView ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *button;
@end

@implementation AddVoiceView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorFromRGB(0xFFFFFF);
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    int a = 0;
    if (iPhoneX) {
        a= 20;
    }
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(106, 56));
        make.top.equalTo(self).with.offset(124 + a);
        make.centerX.equalTo(self.mas_centerX);
    }];
    [self addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(240, 40));
        make.top.equalTo(self).with.offset(206+ a);
        make.centerX.equalTo(self.mas_centerX);
    }];
    [self addSubview:self.button];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(280, 43));
    }];
}

- (void)btnClick
{
    if (self.btnClickBlock) {
        self.btnClickBlock();
    }
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage VoiceCheck_imageWithName:@"icon"]];
    }
    return _imageView;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = UIColorFromRGB(0x333333);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = kFont(14);
        _label.numberOfLines = 0;
        _label.text = @"点击下方按钮进入声纹采集页,请确保周围安静、无噪音!";
    }
    return _label;
}

- (UIButton *)button
{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        [_button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        [_button setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        [_button setBackgroundColor:UIColorFromRGB(0x10A8EA)];
        [_button setTitle:@"添加声纹" forState:UIControlStateNormal];
        _button.layer.cornerRadius = 21.5;
        _button.layer.masksToBounds = YES;
        _button.titleLabel.font = kFont(16);
    }
    return _button;
}

@end
