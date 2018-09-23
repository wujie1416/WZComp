//
//  NSString+CMD.m
//  LoanAcquisition
//
//  Created by sunyue on 15/4/29.
//  Copyright (c) 2015年 wangbin2. All rights reserved.
//

#import "NSString+CMD.h"

@implementation NSString (CMD)

-(NSDictionary *)urlParamsDictionary
{
    if (self && self.length && [self rangeOfString:@"?"].length == 1) {
        NSArray *array = [self componentsSeparatedByString:@"?"];
        if (array && array.count == 2) {
            NSString *paramsStr = array[1];
            if (paramsStr.length) {
                NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
                NSArray *paramArray = [paramsStr componentsSeparatedByString:@"&"];
                for (NSString *param in paramArray) {
                    if (param && param.length) {
                        NSArray *parArr = [param componentsSeparatedByString:@"="];
                        if (parArr.count == 2) {
                            [paramsDict setObject:parArr[1] forKey:parArr[0]];
                        }
                    }
                }
                return paramsDict;
            }else{
                return nil;
            }
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}

#pragma mark - 空字符串转换
+(NSString*)speaceString:(NSString*)string;
{
    if ([string isKindOfClass:[NSNull class]]) {
        return @" ";
    }
    
    if (string.length == 0) {
        string = @" ";
    }
    
    if([string isEqualToString:@"null"])
    {
        string = @" ";
    }
    
    if ([string isEqualToString:@"(null)"])
    {
        string = @" ";
    }
    
    return string;
}
#pragma mark - 去除换行和空格
-(NSString*)strimEnterAndSpace
{
    NSString *string = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    string = [self stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

#pragma mark
#pragma mark - 根据字符串获字体大小获取label高度 [获取label高度 width label长度 aFont 字体大小]
+ (CGSize)heightOfText:(NSString *)text
               theFont:(float)aFontSize MaxSize:(CGSize)textSize
{
    NSDictionary *att = @{NSFontAttributeName:[UIFont systemFontOfSize:aFontSize],
                          NSForegroundColorAttributeName:[UIColor redColor]};
    
    CGSize size       = [text boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:att context:nil].size;
    return size;
}

#pragma mark null or nil change string
+ (NSString *)nullToString:(id)sender
{
    if (sender == [NSNull null]){ return @"";}
    
    if (![sender isKindOfClass:[NSString class]])
    {
        if ([sender isKindOfClass:[NSArray class]]) {
            sender = @"";
        }
        else
        {
            sender = [sender stringValue];
        }
    }
    
    if (   sender == [NSNull null]
        || [sender isKindOfClass:[NSNull class]]
        || sender == nil
        || [sender isEqualToString:@"(null)"]
        || sender == [NSNull null]) {
        return @"";
    }else{
        return sender;
    }
}

#pragma mark
#pragma mark - 金钱格式输出
+(NSString *)amountTOAmountComma :(NSString *)amountstr
{
    amountstr = [NSString nullToString:amountstr];
    if ([amountstr isEqualToString:@""]) {
        return @"0.00";
    }
    amountstr = [NSString stringWithFormat:@"%.2lf",[amountstr doubleValue]];
    NSString *samountstr = [amountstr substringToIndex:amountstr.length - 3];
    NSString *esmountstr = [amountstr substringFromIndex:amountstr.length - 3];
    samountstr = [self fanZhuan:samountstr];
    samountstr = [self fanZhuan:samountstr];
    NSString *resamount = [NSString stringWithFormat:@"%@%@",samountstr,esmountstr];
    return  resamount;
}
+(NSString *)fanZhuan:(NSString *)str
{
    unsigned long len;
    len = [str length];
    unichar a[len];
    for(int i = 0; i < len; i++)
    {
        unichar c = [str characterAtIndex:len-i-1];
        a[i] = c;
    }
    NSString *str1=[NSString stringWithCharacters:a length:len];
    return  str1;
}

#pragma mark
#pragma mark - 需要替换的字符串 location 替换的位置 0 中间 1 开头 2结尾 len 保留字符串长度 character 替换成的字符
+(NSString *) replaceStr :(NSString *)str
                location :(int)location
               savelength:(int)len
                character:(NSString *)character
{
    const int strLength = (int)str.length;int forLength = 0;
    //字符串判断
    if (strLength < len) {
        return str;
    }
    NSRange   srange;
    NSString *sStr = nil,*eStr = nil,*rStr = @"";
    switch (location) {
        case 0:
        {
            if (strLength < len * 2) {
                return str;
            }
            srange = NSMakeRange(0, len);
            sStr   = [str substringWithRange:srange];
            eStr   = [str substringFromIndex:strLength - len];
            forLength = strLength - len * 2;
        }
            break;
        case 1:
        {
            sStr   = @"";
            eStr   = [str substringFromIndex:strLength - len];
            forLength = strLength - len;
        }
            break;
        case 2:
        {
            sStr = [str substringToIndex:len];
            eStr = @"";
            forLength = strLength - len;
        }
            break;
    }
    for (int i = 0; i < forLength; i++)
        rStr = [NSString stringWithFormat:@"%@%@",rStr,character];
    return [NSString stringWithFormat:@"%@%@%@",sStr,rStr,eStr];
}

- (BOOL)isPureInt
{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

- (BOOL)isValidPhoneNum
{
    if ([self isEqualToString:@"-"] ||
        [self isEqualToString:@"+"] ||
        [self isEqualToString:@""] ||
        [self isPureInt]){
        return YES;
    }
    return NO;
}

- (BOOL)includeChinese
{
    for(int i=0; i< [self length];i++)
    {
        int a =[self characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}

- (NSDictionary *)getURLParameters
{
    NSRange range = [self rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *parametersString = [self substringFromIndex:range.location + 1];
    if ([parametersString containsString:@"&"]) {
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents) {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            if (key == nil || value == nil) {
                continue;
            }
            id existValue = [params valueForKey:key];
            if (existValue != nil) {
                if ([existValue isKindOfClass:[NSArray class]]) {
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    [params setValue:items forKey:key];
                } else {
                    [params setValue:@[existValue, value] forKey:key];
                }
            } else {
                [params setValue:value forKey:key];
            }
        }
    } else {
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        if (pairComponents.count == 1) {
            return nil;
        }
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        if (key == nil || value == nil) {
            return nil;
        }
        [params setValue:value forKey:key];
    }
    return params;
}

- (BOOL)isMobleNumber{
    NSString *MOBILE = @"^1[3|4|5|7|8][0-9]\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    if (([regextestmobile evaluateWithObject:self] == YES)){
        return YES;
    }
    return NO;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        return nil;
    }
    return dic;
}

@end
