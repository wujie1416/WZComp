//
//  APIModel.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIModel : NSObject
@property(nonatomic, assign) NSInteger rspCode;
@property(nonatomic, copy) NSString *rspMsg;
@property(nonatomic, copy) NSString *showMsg;
@property(nonatomic, copy) id data;

@end
