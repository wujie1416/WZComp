//
//  VoiceTableViewCell.h
//  AFNetworking
//
//  Created by wujie on 2018/5/17.
//

#import "HYDBaseTableViewCell.h"

@interface VoiceTableViewCell : HYDBaseTableViewCell

@property (nonatomic, strong) UILabel *dataLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *statusButton;

@property (nonatomic, copy) void(^btnClickBlock)(void);

@end
