//
//  UIButton+Init.h
//  HC-HYD
//
//  Created by sakurai on 2017/4/27.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Init)

+ (UIButton *)buttonWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
                         font:(UIFont *)font
                        image:(NSString *)image
              backgroundColor:(UIColor *)backgroundColor;

@end
