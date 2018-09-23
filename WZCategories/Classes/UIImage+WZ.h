//
//  UIImage+WZ.h
//  AFNetworking
//
//  Created by wangling on 2018/1/24.
//

#import <UIKit/UIKit.h>

@interface UIImage (WZ)

+ (UIImage *)wz_imageWithName:(NSString *)imgName bundle:(NSString *)bundleName;
+ (UIImage *)wz_imageWithName:(NSString *)imgName bundle:(NSString *)bundleName ofType:(NSString *)type;

@end
