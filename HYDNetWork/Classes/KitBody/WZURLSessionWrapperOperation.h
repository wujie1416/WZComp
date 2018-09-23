//
//  WZURLSessionWrapperOperation.h
//  AFNetworking
//
//  Created by cheyueyong on 2018/1/30.
//

#import <Foundation/Foundation.h>

@interface WZURLSessionWrapperOperation : NSOperation

+ (instancetype)operationWithURLSessionTask:(NSURLSessionTask*)task;

@end
