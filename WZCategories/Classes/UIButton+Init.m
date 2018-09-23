//
//  UIButton+Init.m
//  HC-HYD
//
//  Created by sakurai on 2017/4/27.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "UIButton+Init.h"

@implementation UIButton (Init)

+ (UIButton *)buttonWithTitle:(NSString *)title
                  titleColor:(UIColor *)titleColor
                        font:(UIFont *)font
                       image:(NSString *)image
             backgroundColor:(UIColor *)backgroundColor {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    button.backgroundColor = backgroundColor;
    return button;
}

@end
