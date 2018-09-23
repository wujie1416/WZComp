//
//  UIDevice+UUID.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/6/2.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <UIKit/UIKit.h>

//keychain关键字
#define keyChainService             @"com.puhui.hyd"
#define keyChainAccountUUID         @"uuid"


@interface UIDevice (UUID)

+ (NSString *)keyChainUUID;

@end
