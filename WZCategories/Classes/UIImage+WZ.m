//
//  UIImage+WZ.m
//  AFNetworking
//
//  Created by wangling on 2018/1/24.
//

#import "UIImage+WZ.h"
#import "NSBundle+WZ.h"

@implementation UIImage (WZ)

+ (UIImage *)wz_imageWithName:(NSString *)imgName bundle:(NSString *)bundleName;
{
    return [self wz_imageWithName:imgName bundle:bundleName ofType:@"png"];
}

+ (UIImage *)wz_imageWithName:(NSString *)imgName bundle:(NSString *)bundleName ofType:(NSString *_Nullable)type;
{
    NSBundle *bundle = [NSBundle wz_bundleWithName:bundleName];
    NSString *wholeImgName = [NSString stringWithFormat:@"%@.%@", imgName, type];
    UIImage* image = [UIImage imageWithContentsOfFile:[[bundle resourcePath] stringByAppendingPathComponent:wholeImgName]];
    return image;
}

@end
