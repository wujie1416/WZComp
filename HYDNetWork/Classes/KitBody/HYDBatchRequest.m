//
//  HYDBatchRequest.m
//  AFNetworking
//
//  Created by 老司机车 on 28/11/2017.
//

#import "HYDBatchRequest.h"
#import "HYDBaseRequestManager.h"
#import "HYDBatchRequestAgent.h"
#import <WZLogger/WZLogging.h>

@interface HYDBatchRequest() <HYDBaseRequestManagerCallBackDelegate>
@property (nonatomic) NSInteger finishedCount;
@end

@implementation HYDBatchRequest

- (void)dealloc {
    WZLogInfo(@"%@ dealloc", self);
    [self clearRequest];
}

- (instancetype)initWithRequestArray:(NSArray<HYDBaseRequestManager *> *)requestArray {
    self = [super init];
    if (self) {
        _requestArray = [requestArray copy];
        _finishedCount = 0;
        for (HYDBaseRequestManager * manager in _requestArray) {
            if (![manager isKindOfClass:[HYDBaseRequestManager class]]) {
                WZLogError(@"Error, request item must be HYDBaseRequestManager instance!");
                return nil;
            }
        }
    }
    return self;
}

- (void)start {
    if (_finishedCount > 0) {
        WZLogError(@"Error! Batch request has already started.");
        return;
    }
    _failedManager = nil;
    [[HYDBatchRequestAgent sharedAgent] addBatchRequest:self];
    for (HYDBaseRequestManager *manager in _requestArray) {
        manager.callBackDelegate = self;
        [manager clearCompletionBlock];
        [manager startTask];
    }
}

- (void)stop {
    _delegate = nil;
    [self clearRequest];
    [[HYDBatchRequestAgent sharedAgent] removeBatchRequest:self];
}

- (void)startWithCompletionBlockWithSuccess:(void (^)(HYDBatchRequest *batchRequest))success
                                    failure:(void (^)(HYDBatchRequest *batchRequest))failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(void (^)(HYDBatchRequest *batchRequest))success
                              failure:(void (^)(HYDBatchRequest *batchRequest))failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearRequest {
    for (HYDBaseRequestManager * manager in _requestArray) {
        [manager cancelTasks];
    }
    [self clearCompletionBlock];
}

- (void)clearCompletionBlock {
        // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}


#pragma mark -- HYDBaseRequestManagerCallBackDelegate

- (void)manager:(HYDBaseRequestManager *)manager didSuccessWithResponse:(APIURLResponse *)response
{
    _finishedCount++;
    if (_finishedCount == _requestArray.count) {
        if ([_delegate respondsToSelector:@selector(batchRequestFinished:)]) {
            [_delegate batchRequestFinished:self];
        }
        if (_successCompletionBlock) {
            _successCompletionBlock(self);
        }
        [self clearCompletionBlock];
        [[HYDBatchRequestAgent sharedAgent] removeBatchRequest:self];
    }
}

- (void)manager:(HYDBaseRequestManager *)manager didFailedWithError:(NSError *)error
{
    _failedManager = manager;
    for (HYDBaseRequestManager *manager in _requestArray) {
        [manager cancelTasks];
    }
    WZLogError(@"[%@] %@ request failed, and error is: %@", [self class], [_failedManager class], error);
    if ([_delegate respondsToSelector:@selector(batchRequestFailed:)]) {
        [_delegate batchRequestFailed:self];
    }
    if (_failureCompletionBlock) {
        _failureCompletionBlock(self);
    }
    [self clearCompletionBlock];
    
    [[HYDBatchRequestAgent sharedAgent] removeBatchRequest:self];
}

@end
