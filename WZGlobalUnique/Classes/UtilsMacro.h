//
//  UtilsMacro.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/23.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#ifndef UtilsMacro_h
#define UtilsMacro_h

//-------------------判空宏------------------------
#define StringIsNullOrEmpty(str) (NO == [str isKindOfClass:[NSString class]] || [str isKindOfClass:[NSNull class]] || str.length <= 0)
#define DictionaryIsNullOrEmpty(dict) (NO == [dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSNull class]] || [dict count] <= 0)
#define ArrayIsNullOrEmpty(arr) (NO == [arr isKindOfClass:[NSArray class]] || [arr isKindOfClass:[NSNull class]] || [arr count] <= 0)

//-------------------机型适配------------------------
#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone4or5 (iPhone4||iPhone5)
//放大版的iphone6等于Iphone5的分辨率
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) : NO)
#define iPhone6P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)
#define iPhoneX  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define ALD(x)      (x * SCREEN_WIDTH/375.0)
#define AHD(y)      (y * SCREEN_HEIGHT/667.0)

//-------------------系统版本------------------------
#define SystemVersionGreaterOrEqualThan(version) ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)
#define IOS8_LATER SystemVersionGreaterOrEqualThan(8.0)
#define IOS9_LATER SystemVersionGreaterOrEqualThan(9.0)
#define IOS10_LATER SystemVersionGreaterOrEqualThan(10.0)
#define IOS11_LATER SystemVersionGreaterOrEqualThan(11.0)


//-------------------快捷创建------------------------
#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;
#define STRONGSELF(weakSelf) __strong __typeof(&*weakSelf) self = weakSelf;
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGBC(aaa) RGBA(aaa,aaa,aaa,1.f)
#define FONT(value) [UIFont systemFontOfSize:value]
#define SMALLFONT(value) (SCREEN_WIDTH == 320 ? [UIFont systemFontOfSize:value-1] :[UIFont systemFontOfSize:value-1])

// rgb颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

//-------------------快捷定义------------------------
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

//UI标注尺寸 转换为 实际尺寸
#define kUIImgWidth 750.0
#define kUIImgHeigth 1334.0
#define kUIAdaptedWidth(width) SCREEN_WIDTH * ((width)/kUIImgWidth)
#define kUIAdaptedHeight(height) SCREEN_HEIGHT * ((height)/kUIImgHeigth)

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
} while (0)

//适配iOS11的scrollView属性改变automaticallyAdjustsScrollViewInsets
#define  adjustsScrollViewInsets_NO(scrollView,vc)\
    SuppressPerformSelectorLeakWarning(\
        if (@available(iOS 11.0, *)) {\
            [scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];\
        } else {\
            vc.automaticallyAdjustsScrollViewInsets = NO;\
        }\
)

#define  adjustsScrollViewInsets_YES(scrollView,vc)\
    SuppressPerformSelectorLeakWarning(\
        if (@available(iOS 11.0, *)) {\
            [scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAlways];\
        } else {\
            vc.automaticallyAdjustsScrollViewInsets = YES;\
        }\
)

#define cornerRadiusView(View, Radius) \
[View.layer setCornerRadius:(Radius)];           \
[View.layer setMasksToBounds:YES];

typedef void(^HYDErrorBlock) (NSError *error);
typedef void(^HYDBlock)(void);

#endif /* UtilsMacro_h */
