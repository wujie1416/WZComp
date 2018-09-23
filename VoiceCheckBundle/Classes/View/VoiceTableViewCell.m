//
//  VoiceTableViewCell.m
//  AFNetworking
//
//  Created by wujie on 2018/5/17.
//

#import "VoiceTableViewCell.h"
#import "Masonry.h"
#import "UtilsMacro.h"
#import "BusMacro.h"

@implementation VoiceTableViewCell

- (void)layoutSubviews
{
    [self addSubview:self.dataLabel];
    [self.dataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(18);
        make.left.equalTo(self).with.offset(15);
        make.size.mas_equalTo(CGSizeMake(150, 14));
    }];
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(40);
        make.left.equalTo(self).with.offset(15);
        make.size.mas_equalTo(CGSizeMake(100, 12));
    }];
    [self addSubview:self.statusButton];
    [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(-15);
        make.size.mas_equalTo(CGSizeMake(150, 65));
    }];
}

- (void)btnClick
{
    if (self.btnClickBlock) {
        self.btnClickBlock();
    }
}

- (UILabel *)dataLabel
{
    if (!_dataLabel) {
        _dataLabel = [[UILabel alloc] init];
        _dataLabel.font = kFont(16);
        _dataLabel.textColor = UIColorFromRGB(0x333333);
    }
    return _dataLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = kFont(12);
        _timeLabel.textColor = UIColorFromRGB(0x999999);
    }
    return _timeLabel;
}

- (UIButton *)statusButton
{
    if (!_statusButton) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _statusButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _statusButton.titleLabel.font = kFont(14);
        [_statusButton addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _statusButton;
}

@end
