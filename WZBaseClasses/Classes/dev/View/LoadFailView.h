//
//  LoadFailView.h
//  HC-HYD
//
//  Created by 罗志超 on 2017/5/19.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LoadFailType) {
    LoadRefreshFail, //刷新错误
    LoadNetFail,     //网络加载错误
    LoadNoData       //加载成功,没有数据
};


@interface LoadFailView : UIView

- (void)showWithType:(LoadFailType)type reFreshBlock:(void(^)(void))block;

@end
