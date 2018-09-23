//
//  HYDBatchRequestAgent.m
//  AFNetworking
//
//  Created by 老司机车 on 28/11/2017.
//

#import "HYDBatchRequestAgent.h"
#import "HYDBatchRequest.h"

@interface HYDBatchRequestAgent()
@property (strong, nonatomic) NSMutableArray<HYDBatchRequest *> *requestArray;
@end

@implementation HYDBatchRequestAgent

+ (HYDBatchRequestAgent *)sharedAgent {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)addBatchRequest:(HYDBatchRequest *)request {
    @synchronized(self) {
        [_requestArray addObject:request];
    }
}

- (void)removeBatchRequest:(HYDBatchRequest *)request {
    @synchronized(self) {
        [_requestArray removeObject:request];
    }
}

@end
