//
//  NSURLRequest+NSURLRequestWithIgnoreSSL.m
//  HC-HYD
//
//  Created by 罗志超 on 2017/7/3.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "NSURLRequest+NSURLRequestWithIgnoreSSL.h"

@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)

//webview证书跳过验证
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
#ifdef DEBUG
    return YES;
#endif
    return NO;
}

@end
