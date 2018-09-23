//
//  NSString+RegExtend.m
//  Carpenter
//
//  Created by cheyy on 15/5/18.
//  Copyright (c) 2015年 cheyy. All rights reserved.
//

#import "NSString+RegExtend.h"
#import "RegExCategories.h"


@implementation NSString (RegExtend)


/**  是否是手机号 */
-(BOOL)isMobileNO{
    return [self isMatch:RX(@"^((13[0-9])|(147)|(15[^4,\\D])|(18[0-9]))\\d{8}$")];
}

-(BOOL)isIdentifyNO{
    return [self isMatch:RX(@"^(\\d{14}|\\d{17})(\\d|[xX])$")];
}

-(BOOL)isValidMoney{
    return ( [self isFloatNum] || [self isIntegerNum] ) && [self doubleValue]>0;
}

-(BOOL)isNumberWith2Point{
    return [self isMatch:RX(@"^[0-9]+([.]?[0-9]+){0,1}$")];
}

-(BOOL)isFloatNum{
    return [self isMatch:RX(@"^[1-9]\\d*\\.\\d*|0\\.\\d*[1-9]\\d*$")];
}

-(BOOL)isIntegerNum{
    return [self isMatch:RX(@"^[1-9]\\d*$")];
}

-(BOOL)isValidateEmail{
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"];
    return [emailTest evaluateWithObject:self];
}

-(NSString*)trimForeZero{
    NSString *tempString = self;
    if([tempString integerValue] == 0 && [tempString doubleValue] == 0){
        return @"";
    }
    while ([tempString hasPrefix:@"0"] && ![[tempString substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"."]){
       tempString = [tempString substringFromIndex:1];
    }
    return tempString;
}

-(NSString*)trimTailZero{
    NSString *tempString = self;
    while ([tempString hasSuffix:@"0"] && [tempString isFloatNum] && ![[tempString substringWithRange:NSMakeRange(tempString.length-2, 1)] isEqualToString:@"."]){
        tempString = [tempString substringToIndex:tempString.length-1];
    }
    return tempString;
}

-(NSString*)trimForeTailZero{
    NSString *tempString = [self trimForeZero];
    return [tempString trimTailZero];
}


/*****************************************
 **              正则邮箱验证             **
 *****************************************
 * @Verify email address format
 * @add by wbin,2013-04-12
 * @param NSString _email 邮箱
 * @return BOOL YES | NO
 *****************************************/
-(BOOL)isValidateEmail:(NSString *)_email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:_email];
}

/*****************************************
 **            正则验证用户名             **
 *****************************************
 * @Verify the user username
 * @add by wbin,2013-04-12
 * @author wbgod_1987@qq.com
 * @param NSString _email 邮箱
 * @parm type 0 纯英文 1 英文 数字 2 英文 数字 首字母须大写 3 英文 数字 或下划线
 * @return BOOL YES | NO
 *****************************************/


-(BOOL) isValidateUserName : (NSString *)_username userNameType :(int) _type userNameLen:(int)_len
{
    _username = [self trimStringSpace:_username];
    if([_username length] < _len)
    {
        return NO;
    }else{
        switch (_type) {
            case 0:
            {
                NSString    *userNameRegex     = @"^[a-zA-Z]+$";
                
                NSPredicate *userNameRegexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];
                
                return [userNameRegexTest evaluateWithObject:_username];
            }
                break;
            case 1:
            {
                NSString *userNameRegex     = @"^[a-zA-Z0-9]+$";
                NSPredicate *userNameRegexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];
                
                return [userNameRegexTest evaluateWithObject:_username];
                
            }
            case 2:
            {
                NSString *userNameRegex     = @"^[A-Z][a-zA-Z0-9]+$";
                NSPredicate *userNameRegexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];
                
                return [userNameRegexTest evaluateWithObject:_username];
            }
                break;
            case 3:
            {
                NSString    *userNameRegex     = @"^[\\|\\-\\_a-zA-Z0-9]+$";
                NSPredicate *userNameRegexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];
                
                return [userNameRegexTest evaluateWithObject:_username];
            }
                break;
        }
        
    }
    return NO;
}


/*****************************************
 **            去除字符串空格             **
 *****************************************
 * @Verify the user username
 * @add by wbin,2013-04-12
 * @author wbgod_1987@qq.com
 * @param NSString _string 字符串
 * @return NSString _string
 *****************************************/
- (NSString *)trimStringSpace : (NSString *) _string
{
    NSCharacterSet *whitespace = [NSCharacterSet  whitespaceAndNewlineCharacterSet];
    
    _string = [_string  stringByTrimmingCharactersInSet:whitespace];
    
    return _string;
}



/*****************************************
 **             验证密码长度              **
 *****************************************
 * @Verify password length
 * @add by wbin,2013-04-12
 * @author wbgod_1987@qq.com
 * @param  NSString _string 字符串
 * @param  int min
 * @param  int max
 * @return BOOL YES | NO
 *****************************************/

-(BOOL)isValidatePassWord :(NSString *) _password min :(int)_min max:(int)_max
{
    _password = [self trimStringSpace:_password];
    
    return ([_password length] >= _min && [_password length] <= _max) ? YES : NO;
}


/*****************************************
 **               验证邮编               **
 *****************************************
 * @Verify zip code
 * @add by wbin,2013-04-15
 * @author wbgod_1987@qq.com
 * @param  NSString _string 字符串
 * @return BOOL YES | NO
 *****************************************/
-(BOOL) isZipCode:(NSString *)_code
{
    _code = [self trimStringSpace:_code];
    NSString    *codeRegex     = @"^[1-9]\\d{5}$";
    NSPredicate *codeRegexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", codeRegex];
    return [codeRegexTest evaluateWithObject:_code];
}

/*****************************************
 **          验证身份证(中国)             **
 *****************************************
 * @Verify the id CARDS
 * @add by wbin,2013-04-15
 * @author wbgod_1987@qq.com
 * @param  NSString _string 字符串
 * @return BOOL YES | NO
 *****************************************/

-(BOOL)isCard : (NSString *)_card
{
    _card = [self trimStringSpace:_card];
    NSString    *cardRegex     = @"^([0-9]{15}|[0-9]{17}[0-9a-z])$";
    NSPredicate *cardRegexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", cardRegex];
    return [cardRegexTest evaluateWithObject:_card];
}

    ///身份号码验证
- (BOOL) validateIdentityCard: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}

/*****************************************
 **              金额验证             **
 *****************************************
 * @
 * @add by wbin,2013-04-11
 * @author wbgod_1987@qq.com
 * @整数位最多十位，小数为最多为两位，可以无小数位
 * @param
 * @return BOOL YES | NO
 *****************************************/

-(BOOL) initValidateMoney :(NSString * )_money
{
    NSString  *moneyRegex  =  @"^[1-9]+\\.[0-9]{0,1}$";
    NSPredicate *moneyTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",moneyRegex];
    return [moneyTest evaluateWithObject:_money];
}

- (BOOL) isQQ :(NSString *)_qqStr
{
    NSString  *qqRegex  =  @"[1-9][0-9]{4,}";
    NSPredicate *qqTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",qqRegex];
    return [qqTest evaluateWithObject:_qqStr];
}

- (BOOL) isInteger :(NSString *)_integer
{
    NSString  *qqRegex  =  @"^[1-9]\\d*$";
    NSPredicate *qqTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",qqRegex];
    return [qqTest evaluateWithObject:_integer];
}
    //验证是不是只有数字和字母
- (BOOL) isNumbersAndLetter :(NSString *)_numLet{
    NSString  *qqRegex  =  @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,16}$";
    NSPredicate *qqTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",qqRegex];
    return [qqTest evaluateWithObject:_numLet];
}
    //字母数字中文
- (BOOL) zimushuzizhongwen: (NSString *)zszwStr
{
    NSString *zszw = @"^[a-zA-Z0-9\u4e00-\u9fa5]+$";//中文，字母，数字组成的字符串，不要求三者同时出现
    NSPredicate *zszwPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",zszw];
    return [zszwPredicate evaluateWithObject:zszwStr];
}

    //验证是不是包含数字
- (BOOL) isContainNumber:(NSString *)num{
    NSString  *qqRegex  =  @"^(?=.*[0-9]).*$";
    NSPredicate *qqTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",qqRegex];
    return [qqTest evaluateWithObject:num];
}
- (BOOL)isValidPWD:(NSString *)dlrPwd
{
        //1.规则
    NSString *reg1 =@".*[0-9]+.*";
    NSString *reg2 =@".*[a-zA-Z]+.*";
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg1];
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg2];
    
        //2.判断是否合规
    if ([pred1 evaluateWithObject:dlrPwd] && [pred2 evaluateWithObject:dlrPwd])
    {
        return YES;
    }
    return NO;
}

- (BOOL)isWeixinNum:(NSString *)weixinNum
{
    if (weixinNum.length <= 50) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isValidPassWord
{
    NSString *reg1 =@".*[0-9]+.*";
    NSString *reg2 =@".*[a-zA-Z]+.*";
    NSString *reg3 =@".*[-~+_!@#$%^&*(),+|{}:<>?]+.*";
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg1];
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg2];
    NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg3];
    if ([pred1 evaluateWithObject:self] && [pred2 evaluateWithObject:self] && ![pred3 evaluateWithObject:self]){
        return YES;
    }
    return NO;
}

    ///银行卡判断
- (BOOL)checkCardNo:(NSString*)cardNo
{
    int oddsum = 0;     //奇数求和
    int evensum = 0;    //偶数求和
    int allsum = 0;
    int cardNoLength = (int)[cardNo length];
    int lastNum = [[cardNo substringFromIndex:cardNoLength-1] intValue];
    
    cardNo = [cardNo substringToIndex:cardNoLength - 1];
    for (int i = cardNoLength -1 ; i>=1;i--) {
        NSString *tmpString = [cardNo substringWithRange:NSMakeRange(i-1, 1)];
        int tmpVal = [tmpString intValue];
        if (cardNoLength % 2 ==1 ) {
            if((i % 2) == 0){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }else{
            if((i % 2) == 1){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }
    }
    
    allsum = oddsum + evensum;
    allsum += lastNum;
    if((allsum % 10) == 0)
        return YES;
    else
        return NO;
}
@end
