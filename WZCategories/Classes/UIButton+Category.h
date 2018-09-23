//
//  UIButton+Category.h
//  HYD1.0
//
//  Created by wangbin2 on 16/1/11.
//  Copyright © 2016年 wangbin2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIButton (Category)

/**
*  倒计时按钮
*
*  @param totalTime 倒计时总时间
*  @param title     还没倒计时的title
*  @param subTitle  倒计时中的子名字，如时、分
*/
- (void)startWithTime:(NSInteger)totalTime title:(NSString *)title countDownTitle:(NSString *)subTitle;

- (void)startWithTime:(NSInteger)totalTime title:(NSString *)title countDownTitle:(NSString *)subTitle normalColor:(UIColor *)normalColor color:(UIColor *)color;
@end
