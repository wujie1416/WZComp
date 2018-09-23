//
//  UIBarButtonItem+backItem.h
//  ZaMai
//
//  Created by hc_hzc on 16/3/28.
//  Copyright © 2016年 ztp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (backItem)
+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(NSString *)image highImage:(NSString *)highImage;

@end
