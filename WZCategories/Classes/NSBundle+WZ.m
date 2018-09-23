//
//  NSBundle+WZ.m
//  AFNetworking
//
//  Created by wangling on 2018/1/24.
//

#import "NSBundle+WZ.h"

@implementation NSBundle (WZ)

+ (NSBundle *)wz_bundleWithName:(NSString *)bundleName
{
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"]];
}
@end
