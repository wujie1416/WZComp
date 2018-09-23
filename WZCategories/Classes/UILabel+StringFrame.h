//
//  UILabel+StringFrame.h
//  AixintripClient
//
//  Created by 赵黛阳 on 15/4/17.
//

#import <UIKit/UIKit.h>

@interface UILabel (StringFrame)


//计算文字的高度和宽度
- (CGSize)boundingRectWithSize:(CGSize)size;

//计算文件宽度
- (CGFloat)widthForFont:(UIFont *)font;

//计算文字高度
- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width;


- (CGFloat)widthForLabel;

- (CGFloat)heightWithWidth:(CGFloat) width;
@end
