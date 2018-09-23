//
//  HYDRefreshFooter.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/4/14.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "HYDRefreshFooter.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+WZ.h"
#import "WZBaseCLassMacro.h"

@interface HYDRefreshFooter()
@property (nonatomic, weak) UIImageView *logo;
@property(nonatomic,weak)UILabel *lable;
@property(nonatomic,assign)BOOL isbb;
@end

@implementation HYDRefreshFooter
//初始化子空间
- (void)prepare
{
    [super prepare];
    
    self.mj_h = 50;
    UILabel *lable = [[UILabel alloc]init];
    self.lable = lable;
    [self addSubview:self.lable];
    UIImage *image = [UIImage wz_imageWithName:@"icon_refresh" bundle:kWZBaseCLassBundleName];
    UIImageView *logo = [[UIImageView alloc] initWithImage:image];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:logo];
    self.logo = logo;
    [self star];
}

//设置尺寸
- (void)placeSubviews
{
    [super placeSubviews];
    
    self.logo.bounds = CGRectMake(self.logo.bounds.origin.x, self.logo.bounds.origin.y, self.logo.image.size.width, self.logo.image.size.height);
    self.logo.center = CGPointMake(self.mj_w * 0.5, - self.logo.mj_h + 60);
}

//监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
}

// 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
}

// 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
    
}

// 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    CFTimeInterval pausedTime;
    
    switch (state) {
        case MJRefreshStatePulling:
            self.isbb = YES;
            self.logo.hidden = NO;
            self.lable.hidden = YES;
            self.logo.layer.speed = 1.0;
            self.logo.layer.beginTime = 0.0;
            pausedTime = [self.logo.layer timeOffset];
            CFTimeInterval timeSincePause = [self.logo.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
            self.logo.layer.beginTime = timeSincePause;
            break;
        case MJRefreshStateRefreshing:
            self.logo.hidden = NO;
            self.lable.hidden = YES;
            self.isbb = NO;
            pausedTime = [self.logo.layer convertTime:CACurrentMediaTime() fromLayer:nil];
            self.logo.layer.speed = 0.0;
            self.logo.layer.timeOffset = pausedTime;
            
            break;
        case MJRefreshStateNoMoreData:
            self.logo.hidden = YES;
            self.lable.hidden = NO;
            self.lable.frame = self.bounds;
            self.lable.textAlignment = NSTextAlignmentCenter;
            self.lable.text = @"已经加载完毕全部数据了";
            
            
            break;
        default:
            break;
    }
}
-(void)star
{
    //设置自定义动画
    CABasicAnimation *monkeyAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    monkeyAnimation.toValue = [NSNumber numberWithFloat:2.0 *M_PI];
    monkeyAnimation.duration = 1.5f;
    monkeyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    monkeyAnimation.cumulative = NO;
    monkeyAnimation.removedOnCompletion = NO; //No Remove
    
    monkeyAnimation.repeatCount = FLT_MAX;
    [self.logo.layer addAnimation:monkeyAnimation forKey:@"AnimatedKey"];
    [self.logo stopAnimating];
    
    // 加载动画不播放
    self.logo.layer.speed = 0.0;
}

// 监听拖拽比例
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    
    
}
@end
