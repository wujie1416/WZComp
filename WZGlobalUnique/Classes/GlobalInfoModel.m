//
//  GlobalInfoModel.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/3/24.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "GlobalInfoModel.h"

@implementation GlobalInfoModel

+ (GlobalInfoModel *)sharedGlobal
{
    static GlobalInfoModel *global = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        global = [[self alloc] initWithCache];
    });
    return global;
}

- (id)initWithCache
{
    self = [super init];
    if (self) {
        self = [self reload]?:self;
    }
    return self;
}

+ (void)saveTokenId:(NSString *)tokenId
{
    GlobalInfoModel *global = [GlobalInfoModel sharedGlobal];
    global.tokenId = tokenId;
    global.tokenIdVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [global save];
}

#pragma mark -- getter & setter
- (BOOL)isOpenPermission
{
#if DEBUG
    return YES;
#endif
    return _isOpenPermission;
}
@end
