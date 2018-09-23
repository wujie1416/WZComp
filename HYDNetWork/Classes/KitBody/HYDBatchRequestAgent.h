//
//  HYDBatchRequestAgent.h
//  AFNetworking
//
//  Created by 老司机车 on 28/11/2017.
//

#import <Foundation/Foundation.h>

@class HYDBatchRequest;

@interface HYDBatchRequestAgent : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

    ///  Get the shared batch request agent.
+ (HYDBatchRequestAgent *)sharedAgent;

    ///  Add a batch request.
- (void)addBatchRequest:(HYDBatchRequest *)request;

    ///  Remove a previously added batch request.
- (void)removeBatchRequest:(HYDBatchRequest *)request;

@end
