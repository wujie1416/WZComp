//
//  WZStatisticHelper.h
//  HC-HYD
//
//  Created by 老司机车 on 20/11/2017.
//  Copyright © 2017 cheyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "WZLogFileUtil.h"

#define  kLogVersion                 @"2.0.1"
#define  kBigDataLogVersion    @"1.0"

extern NSString *const kWzStatisticLogIdentifier;

@interface UIView (Statistics)
@property (nonatomic, copy) NSString *wzTag; //网众平台的唯一标识
@end

@interface UITableView (Statistics)
@end

@interface UICollectionView (Statistics)
@end

@interface WKWebView (Statistic)
@end

@interface UIWebView (Statistic)
@end

@interface UIControl (Statistics)
@property (nonatomic, assign) NSTimeInterval hyd_acceptEventInterval;// 可以用这个给重复点击加间隔
@end

@interface UIViewController(Statistics)
@property(nonatomic, strong, class) NSString *wzLastBuriedPageCode;
@property(nonatomic, strong, class) NSString *wzCurPagePageCode;
@property(nonatomic, strong, class) NSString *wzPageEnterTime;
@property(nonatomic, strong, class) NSMutableArray *wzBuriedEventDataBase;
@end

@interface WZStatisticHelper : NSObject

/**
     统计进入某个页面
 */
+ (void)didEnterPageVc:(UIViewController *)page;

/**
     统计离开某个页面
 */
+ (void)didLeavePageVc:(UIViewController *)page;

/**
     埋点：记录按钮、输出框的上报事件
 */
+ (void)recordWithWzTag:(NSString *)wzTag fromSender:(id)sender action:(SEL)action to:(id)target;

/**
 埋点：上报浏览页面的埋点数据
 */
+ (void)reportPvBuryData;

/**
     埋点：上报服务端埋点的数据
 */
+ (void)reportWithData:(NSDictionary *)data;
@end

