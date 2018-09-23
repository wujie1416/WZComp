//
//  UIBarButtonItem+backItem.m
//  ZaMai
//
//  Created by hc_hzc on 16/3/28.
//  Copyright © 2016年 ztp. All rights reserved.
//

#import "UIBarButtonItem+backItem.h"

@implementation UIBarButtonItem (backItem)
+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(NSString *)image highImage:(NSString *)highImage
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    // 设置图片
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highImage] forState:UIControlStateHighlighted];
    btn.imageEdgeInsets  = UIEdgeInsetsMake(0, 0, 0, -10);
    btn.contentMode = UIViewContentModeCenter;
    // 设置尺寸
    btn.frame = CGRectMake(0, 0,btn.currentImage.size.width + 5, btn.currentImage.size.height + 5);
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

@end
