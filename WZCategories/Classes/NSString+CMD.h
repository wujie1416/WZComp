//
//  NSString+CMD.h
//  LoanAcquisition
//
//  Created by sunyue on 15/4/29.
//  Copyright (c) 2015年 wangbin2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CMD)


/**
 *  将url中的参数已字典形式返回
 *  @return 返回参数字典
 */
-(NSDictionary *)urlParamsDictionary;

/**
 *  将字符串中：nil字符串 转变为 空格
 *
 *  @param string 需要更改的字符串
 *
 *  @return 去除nil后的字符串
 */
+(NSString*)speaceString:(NSString*)string;
/**
 *  去除换行和空格转换为@""，校验输入框是否为空
 *
 *  @return 修正后的字符串
 */
-(NSString*)strimEnterAndSpace;
/**
 *  获取字体实际占用 size
 *
 *  @param text      需计算Size的文字
 *  @param aFontSize 传入文字的字体大小
 *
 *  @return 文字实际占用大小
 */
+ (CGSize)heightOfText:(NSString *)text
               theFont:(float)aFontSize MaxSize:(CGSize)textSize;
/**
 *  将null and nil  转换 string
 *
 *  @param sender 需修正的对象（NULL/nil）
 *
 *  @return 修正后的字符
 */
+ (NSString *)nullToString:(id)sender;

/**
 *  金额格式化
 *
 *  @param amountstr 需要修正 （NSString *）金额数
 *
 *  @return 修正后 规范格式的字符串
 */
+(NSString *)amountTOAmountComma : (NSString *)amountstr;
/**
 *  需要替换的字符串 location
 *
 *  @param str       需修正字符串
 *  @param location  需替换的字符位置（0 中间 1 开头 2结尾）
 *  @param len       需要保留的字符串长度
 *  @param character 替代符
 *
 *  @return 修正后字符串
 */
+(NSString *) replaceStr : (NSString *)str
                location : (int) location
              savelength : (int) len
               character : (NSString *)character;

//是否是有效的电话或者手机号输入数字
- (BOOL)isValidPhoneNum;

/**
 字符串是否为纯数字
 */
- (BOOL)isPureInt;

//是否有中文
- (BOOL)includeChinese;

//获取url中的参数
- (NSDictionary *)getURLParameters;

//json转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

//判断是否是电话号码
@property (readonly)BOOL isMobleNumber;
@end
