//
//  RecorderView.m
//  AFNetworking
//
//  Created by wujie on 2018/5/18.
//

#import "RecorderView.h"
#import "Masonry.h"
#import "UtilsMacro.h"
#import "BusMacro.h"
#import "UIImage+VoiceCheck.h"

@interface RecorderView()
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITextView *textView;
@end


@implementation RecorderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.timeLength = 60;
        self.second = 00;
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI
{
    int a = 0;
    if (iPhoneX) {
        a= 20;
    }
    
    [self addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(65 + a);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.size.height.mas_equalTo(34);
    }];
    
    [self.titleView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(23);
        make.right.mas_equalTo(-53);
        make.size.height.mas_equalTo(34);
    }];
    
    [self.titleView addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(-12);
        make.size.mas_equalTo(CGSizeMake(33, 33));
    }];
    
    [self addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(123 + a);
        make.left.mas_equalTo(23);
        make.right.mas_equalTo(-23);
        make.bottom.mas_equalTo(-224);
    }];
    
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-214);
        make.height.mas_offset(60);
    }];
    
    [self addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-186);
        make.height.mas_equalTo(1);
    }];
    
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(23);
        make.bottom.mas_equalTo(-159);
        make.size.mas_equalTo(CGSizeMake(100, 18));
    }];
    
    [self addSubview:self.dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-23);
        make.bottom.mas_equalTo(-159);
        make.size.mas_equalTo(CGSizeMake(100, 18));
    }];
    
    [self addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(63);
        make.bottom.mas_equalTo(-59);
        make.size.mas_equalTo(CGSizeMake(47, 47));
    }];
    
    [self addSubview:self.recordButton];
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-51);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(62, 62));
    }];
    
    [self addSubview:self.commitButton];
    [self.commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-63);
        make.bottom.mas_equalTo(-59);
        make.size.mas_equalTo(CGSizeMake(47, 47));
    }];
}

//播放进度条设置
- (void)setPlaySecond:(NSInteger)playSecond
{
    if (playSecond < 0 || playSecond > self.timeLength * 60) {
        return;
    }
    _playSecond = playSecond;
    self.progressView.progress = self.playSecond / ((CGFloat)self.timeLength * 60);
    [self updatePlayLabel];
}
//更新时间
- (void)updatePlayLabel
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%02lds/%02lds",self.playSecond / 60,self.timeLength]];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:UIColorFromRGB(0xFB1717)
                    range:NSMakeRange(0, 3)];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:UIColorFromRGB(0xFFFFFF)
                    range:NSMakeRange(3, 4)];
    self.timeLabel.attributedText = attrStr;
}

//录音进度条时间设置
- (void)setSecond:(NSInteger)second
{
    if(second < 0 || second > self.timeLength * 60) {
        return;
    }
    _second = second;
    self.progressView.progress = self.second / ((CGFloat)self.timeLength * 60);
    [self updateLabel];
}
//更新时间
- (void)updateLabel
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%02lds/%02lds",self.second / 60,self.timeLength]];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:UIColorFromRGB(0xFB1717)
                    range:NSMakeRange(0, 3)];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:UIColorFromRGB(0xFFFFFF)
                    range:NSMakeRange(3, 4)];
    self.timeLabel.attributedText = attrStr;
}

- (void)play
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playButtonClick)]) {
        [self.delegate playButtonClick];
    }
}

- (void)record
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordButtonClick)]) {
        [self.delegate recordButtonClick];
    }
}

- (void)commit
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commitButtonClick)]) {
        [self.delegate commitButtonClick];
    }
}

- (void)setText:(NSString *)text
{
    _text = text.copy;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSKernAttributeName:@(3)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    self.textView.attributedText = attributedString;
    self.textView.textColor = UIColorFromRGB(0xD4D4D4);
    self.textView.font = kFont(15);
}

- (void)close
{
    int a = 0;
    if (iPhoneX) {
        a = 20;
    }
    [self.titleLabel removeFromSuperview];
    [self.closeButton removeFromSuperview];
    [self.titleView removeFromSuperview];
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(89 + a);
        make.left.mas_equalTo(23);
        make.right.mas_equalTo(-23);
        make.bottom.mas_equalTo(-224);
    }];
}

- (UIView *)titleView
{
    if (!_titleView) {
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    }
    return _titleView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"请朗读文字并录音，录音时长不可低于30秒。";
        _titleLabel.font = kFont(12);
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];
    }
    return _titleLabel;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage VoiceCheck_imageWithName:@"x"] forState:UIControlStateNormal];
        _closeButton.imageEdgeInsets = UIEdgeInsetsMake(11, 11, 11, 11);
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = UIColorFromRGB(0xD4D4D4);
        _textView.font = kFont(15);
        [_textView setEditable:NO];
    }
    return _textView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage VoiceCheck_imageWithName:@"pic_mask_bg"]];
    }
    return _imageView;
}

- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progress = 0;
        _progressView.trackTintColor = UIColorFromRGB(0x5E5E5E);
        _progressView.progressTintColor = UIColorFromRGB(0xF53231);
    }
    return _progressView;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%02lds/%02lds",self.second,self.timeLength]];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:UIColorFromRGB(0xFB1717)
                        range:NSMakeRange(0, 3)];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:UIColorFromRGB(0xFFFFFF)
                        range:NSMakeRange(3, 4)];
        _timeLabel.attributedText = attrStr;
        _timeLabel.font = kFont(16);
    }
    return _timeLabel;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.text = @"2018/03/22";
        _dateLabel.textColor = UIColorFromRGB(0x89898E);
        _dateLabel.font = kFont(14);
        _dateLabel.textAlignment = NSTextAlignmentRight;
        _dateLabel.alpha = 0.5;
    }
    return _dateLabel;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setEnabled:NO];
        [_playButton setBackgroundImage:[UIImage VoiceCheck_imageWithName:@"play_enabled"] forState:UIControlStateNormal];
        [_playButton setBackgroundImage:[UIImage VoiceCheck_imageWithName:@"pause"] forState:UIControlStateSelected];
        [_playButton setBackgroundImage:[UIImage VoiceCheck_imageWithName:@"play_disabled"] forState:UIControlStateDisabled];
    }
    return _playButton;
}

- (UIButton *)recordButton
{
    if (!_recordButton) {
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordButton addTarget:self action:@selector(record) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton setBackgroundImage:[UIImage VoiceCheck_imageWithName:@"record_enabled"] forState:UIControlStateNormal];
        [_recordButton setBackgroundImage:[UIImage VoiceCheck_imageWithName:@"resume"] forState:UIControlStateSelected];
        [_recordButton setBackgroundImage:[UIImage VoiceCheck_imageWithName:@"record_disabled"] forState:UIControlStateDisabled];
    }
    return _recordButton;
}

- (UIButton *)commitButton
{
    if (!_commitButton) {
        _commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _commitButton.titleLabel.font = kFont(14);
        _commitButton.titleLabel.textColor = [UIColor whiteColor];
        [_commitButton addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
        [_commitButton setEnabled:NO];
        [_commitButton setBackgroundImage:[UIImage VoiceCheck_imageWithName:@"submit_enabled"] forState:UIControlStateNormal];
        [_commitButton setBackgroundImage:[UIImage VoiceCheck_imageWithName:@"submit_disabled"] forState:UIControlStateDisabled];
    }
    return _commitButton;
}

@end
