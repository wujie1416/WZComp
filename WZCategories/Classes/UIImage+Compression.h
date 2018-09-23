//
//  UIImage+Compression.h
//  HC-HYD
//
//  Created by 罗志超 on 2017/4/19.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compression)

/**
 压缩图片文件

 @param myimage 要压缩的图片
 @return 压缩完成的图片
 */
+ (NSData *)compressImageData:(UIImage *)myimage;

@end
