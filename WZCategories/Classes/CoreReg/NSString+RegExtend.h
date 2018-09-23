//
//  NSString+RegExtend.h
//  Carpenter
//
//  Created by cheyy on 15/5/18.
//  Copyright (c) 2015年 cheyy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RegExtend)

/**  是否是手机号 */
@property (nonatomic,assign,readonly) BOOL isMobileNO;

/** 是否是合法的身份证号*/
@property (nonatomic, assign,readonly) BOOL isIdentifyNO;

/** 是否是正浮点数或者正整数*/
@property (nonatomic,assign,readonly) BOOL isValidMoney;

/** 是否是整数或者最多允许两位小数点的数字*/
@property (nonatomic,assign,readonly) BOOL isNumberWith2Point;

/** 是否是正浮点数*/
@property (nonatomic,assign,readonly) BOOL isFloatNum;

/** 是否是正整数*/
@property (nonatomic,assign,readonly) BOOL isIntegerNum;

/** 是否是邮箱*/
@property (nonatomic,assign,readonly) BOOL isValidateEmail;

/** 去除整数前的0*/
-(NSString*)trimForeZero;

/** 去除小数末尾的0--若都是0的话，小数点后保留一位0*/
-(NSString*)trimTailZero;

/** 去除小数首尾的0*/
-(NSString*)trimForeTailZero;

    //邮箱格式验证
-(BOOL) isValidateEmail    :(NSString * )_email ;

    //去除字符串两侧空格
-(NSString *)trimStringSpace : (NSString *) _string;

    //判断字符串长度 是否规定长度及类型
-(BOOL) isValidateUserName : (NSString *)_username userNameType :(int) _type userNameLen:(int)_len;

    //判断字符串是否在规定范围内
-(BOOL)isValidatePassWord :(NSString *) _password min :(int)_min max:(int)_max;

    //判断邮编是否合法
-(BOOL) isZipCode:(NSString *)_code;

    //身份证验证(中国)
-(BOOL)isCard : (NSString *)_card;

    ///身份号码验证
- (BOOL) validateIdentityCard: (NSString *)identityCard;

    //金额验证
-(BOOL) initValidateMoney :(NSString * )_money;

- (BOOL) isQQ :(NSString *)_qqStr;

- (BOOL) isInteger :(NSString *)_integer;

    //验证是不是包含数字和字母
- (BOOL) isNumbersAndLetter :(NSString *)_numLet;

- (BOOL) zimushuzizhongwen: (NSString *)identityCard;


    //验证是不是包含数字
- (BOOL) isContainNumber:(NSString *)num;
    //
- (BOOL)isValidPWD:(NSString *)dlrPwd;

    //验证是不是微信号
- (BOOL)isWeixinNum:(NSString *)weixinNum;

    //字母加数字
- (BOOL)isValidPassWord;

    //验证银行卡号
- (BOOL)checkCardNo:(NSString*)cardNo;

@end
