//
//  RecorderView.h
//  AFNetworking
//
//  Created by wujie on 2018/5/18.
//

#import <UIKit/UIKit.h>

@protocol RecorderViewDelegate <NSObject>
- (void)playButtonClick;
- (void)recordButtonClick;
- (void)commitButtonClick;
@end

@interface RecorderView : UIView
@property (nonatomic, assign) id<RecorderViewDelegate>delegate;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) NSInteger second; //0 - 3600
@property (nonatomic, assign) NSInteger timeLength; //总时间长
@property (nonatomic, assign) NSInteger playSecond; //0 - 3600
@property (nonatomic, strong) UILabel *dateLabel;//日期
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *commitButton;
@end
