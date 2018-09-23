//
//  UIImage+VoiceCheck.m
//  AFNetworking
//
//  Created by wujie on 2018/5/18.
//

#import "UIImage+VoiceCheck.h"

@implementation UIImage (VoiceCheck)

+ (nullable UIImage *)VoiceCheck_imageWithName:(NSString *)imgName
{
    return [self VoiceCheck_imageWithName:imgName ofType:@"png"];
}

+ (nullable UIImage *)VoiceCheck_imageWithName:(NSString *)imgName ofType:(NSString *)type
{
    static NSBundle *lgBundle = nil;
    if (lgBundle == nil) {
        lgBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"VoiceCheckBundle" ofType:@"bundle"]];
    }
    NSString *wholeImgName = [NSString stringWithFormat:@"%@.%@", imgName, type];
    UIImage* image = [UIImage imageWithContentsOfFile:[[lgBundle resourcePath] stringByAppendingPathComponent:wholeImgName]];
    return image;
}

@end
