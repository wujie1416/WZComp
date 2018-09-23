//
//  UIView+Line.h
//  magazineiosapp
//
//  Created by FU JUN on 16/3/28.
//  Copyright © 2016年 cmkj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LineType) {
    LineLeft = 0,
    LineTop,
    LineRight,
    LineBottom,
};

@interface UIView (Line)

/**
 * 给某一个方向增加1像素的边线，默认是浅灰色的
 */
- (void)addEdgeLine:(LineType)linetype;


/**
 * 给某一个方向增加1像素的边线，指定边线颜色
 */
- (void)addEdgeLine:(LineType)linetype lineColor:(UIColor *)lineCorlor;

/**
 * 给某一个方向增加边线，指定边线颜色和线条宽度
 */
- (void)addEdgeLine:(LineType)linetype lineColor:(UIColor *)lineCorlor lineWidth:(CGFloat)lineWidth;

@end
