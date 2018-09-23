//
//  GlobalInfoModel.h
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import <HYDCache/HYDCache.h>

@interface GlobalInfoModel : HYDCache

@property (nonatomic, assign) BOOL showWeNewPrompt;             //0 new标签提示
@property (nonatomic, assign) BOOL showWeBorrowInquiryNewPrompt;//1
@property (nonatomic, assign) BOOL showWeBackBorrowNewPrompt;   //2
@property (nonatomic, assign) BOOL showWeBackListNewPrompt;     //3
@property (nonatomic, copy) NSString *tokenIdVersion;           //和token对应的版本号
@property (nonatomic, copy) NSString *tokenId;                  //用户的信息token
@property (nonatomic, copy) NSString *deviceToken;              //推送通知的deviceToken
@property (nonatomic, copy) NSString *permissionSetting;        //权限设置（应对审核）
@property (nonatomic, assign) BOOL isOpenPermission;            //权限是否已开启

/**
 借款时，选择金额后需要提示注意事项的View，全局只提示一次
 */
@property (nonatomic, assign) BOOL borrowAttentioned;

+ (GlobalInfoModel *)sharedGlobal;

+ (void)saveTokenId:(NSString *)tokenId;

- (id)initWithCache;

@end
