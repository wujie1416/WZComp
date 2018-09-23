//
//  UILabel+Init.h
//  HC-HYD
//
//  Created by sakurai on 2017/4/27.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Init)

+ (UILabel *)labelWithText:(NSString *)text
             textAlignment:(NSTextAlignment)textAlignment
                 textColor:(UIColor *)textColor
                      font:(UIFont *)font
           backgroundColor:(UIColor *)backgroundColor;

@end
