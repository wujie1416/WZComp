//
//  UIButton+Category.m
//  HYD1.0
//
//  Created by wangbin2 on 16/1/11.
//  Copyright © 2016年 wangbin2. All rights reserved.
//

#import "UIButton+Category.h"

@implementation UIButton (Category)

// 倒计时按钮
- (void)startWithTime:(NSInteger)totalTime title:(NSString *)title countDownTitle:(NSString *)subTitle
{
    //倒计时时间
    __block NSInteger timeOut = totalTime;
    //创建队列
    dispatch_queue_t queue    = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer  = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //每秒执行一次
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        
        //倒计时结束，关闭
        if (timeOut <= 0) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.enabled = YES;
                [self setTitle:title forState:UIControlStateNormal];
                [self setTitle:title forState:UIControlStateHighlighted];
                self.userInteractionEnabled = YES;
            });
        } else {
            //int seconds = timeOut % 60;
            int seconds          = (int)timeOut--;
            NSString *timeStr    = [NSString stringWithFormat:@"%0.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.enabled = NO;
                [self setTitle:[NSString stringWithFormat:@"%@%@",timeStr,subTitle] forState:UIControlStateNormal];
                [self setTitle:[NSString stringWithFormat:@"%@%@",timeStr,subTitle] forState:UIControlStateHighlighted];
                self.userInteractionEnabled = NO;
            });
            //timeOut--;
        }
    });
    dispatch_resume(_timer);
}

- (void)startWithTime:(NSInteger)totalTime title:(NSString *)title countDownTitle:(NSString *)subTitle normalColor:(UIColor *)normalColor color:(UIColor *)color
{
    //倒计时时间
    __block NSInteger timeOut = totalTime;
    //创建队列
    dispatch_queue_t queue    = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer  = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //每秒执行一次
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{

        //倒计时结束，关闭
        if (timeOut <= 0) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.enabled = YES;
                [self setTitle:title forState:UIControlStateNormal];
                [self setTitle:title forState:UIControlStateHighlighted];
                self.backgroundColor = color;
                self.userInteractionEnabled = YES;
            });
        } else {
            //int seconds = timeOut % 60;
            int seconds          = (int)timeOut--;
            NSString *timeStr    = [NSString stringWithFormat:@"%0.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.enabled = NO;
                [self setTitle:[NSString stringWithFormat:@"%@%@",timeStr,subTitle] forState:UIControlStateNormal];
                [self setTitle:[NSString stringWithFormat:@"%@%@",timeStr,subTitle] forState:UIControlStateHighlighted];
                self.backgroundColor = normalColor;
                self.userInteractionEnabled = NO;
            });
            //timeOut--;
        }
    });
    dispatch_resume(_timer);
}

@end
