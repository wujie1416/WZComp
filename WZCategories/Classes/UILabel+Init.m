//
//  UILabel+Init.m
//  HC-HYD
//
//  Created by sakurai on 2017/4/27.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "UILabel+Init.h"

@implementation UILabel (Init)

+ (UILabel *)labelWithText:(NSString *)text
            textAlignment:(NSTextAlignment)textAlignment
                textColor:(UIColor *)textColor
                     font:(UIFont *)font
          backgroundColor:(UIColor *)backgroundColor {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textAlignment = textAlignment;
    label.textColor = textColor;
    label.font = font;
    label.backgroundColor = backgroundColor;
    return label;
}

@end
