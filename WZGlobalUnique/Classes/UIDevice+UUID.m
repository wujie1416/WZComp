//
//  UIDevice+UUID.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/6/2.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "UIDevice+UUID.h"
#import <SAMKeychain/SAMKeychain.h>


@implementation UIDevice (UUID)

+ (NSString *)keyChainUUID
{
    NSString *strUUID = [SAMKeychain passwordForService:keyChainService account:keyChainAccountUUID];
    if (nil == strUUID || 1 > strUUID.length)
    {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        assert(uuid != NULL);
        CFStringRef uuidStr;
        uuidStr = CFUUIDCreateString(NULL, uuid);
        assert(uuidStr != NULL);
        strUUID = [NSString stringWithFormat:@"%@", uuidStr];
        assert(strUUID != nil);
        CFRelease(uuidStr);
        CFRelease(uuid);
        
        [SAMKeychain setPassword:strUUID forService:keyChainService account:keyChainAccountUUID];
    }
    
    return strUUID;
}

@end
