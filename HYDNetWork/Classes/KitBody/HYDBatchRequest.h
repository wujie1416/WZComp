//
//  HYDBatchRequest.h
//  AFNetworking
//
//  Created by 老司机车 on 28/11/2017.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HYDBaseRequestManager;
@class HYDBatchRequest;

@protocol HYDBatchRequestDelegate <NSObject>

@optional
    ///  Tell the delegate that the batch request has finished successfully/
    ///  @param batchRequest The corresponding batch request.
- (void)batchRequestFinished:(HYDBatchRequest *)batchRequest;

    ///  Tell the delegate that the batch request has failed.
    ///  @param batchRequest The corresponding batch request.
- (void)batchRequestFailed:(HYDBatchRequest *)batchRequest;
@end

@interface HYDBatchRequest : NSObject

    ///  All the requests are stored in this array.
@property (nonatomic, strong, readonly) NSArray<HYDBaseRequestManager *> *requestArray;

    ///  The delegate object of the batch request. Default is nil.
@property (nonatomic, weak, nullable) id<HYDBatchRequestDelegate> delegate;

    ///  The success callback. Note this will be called only if all the requests are finished.
    ///  This block will be called on the main queue.
@property (nonatomic, copy, nullable) void (^successCompletionBlock)(HYDBatchRequest *);

    ///  The failure callback. Note this will be called if one of the requests fails.
    ///  This block will be called on the main queue.
@property (nonatomic, copy, nullable) void (^failureCompletionBlock)(HYDBatchRequest *);

    ///  The first requestManager that failed (and causing the batch request to fail).
@property (nonatomic, strong, readonly, nullable) HYDBaseRequestManager *failedManager;

    ///  Creates a `YTKBatchRequest` with a bunch of requests.
    ///
    ///  @param requestArray requests useds to create batch request.
    ///
- (instancetype)initWithRequestArray:(NSArray<HYDBaseRequestManager *> *)requestArray;

    ///  Set completion callbacks
- (void)setCompletionBlockWithSuccess:(nullable void (^)(HYDBatchRequest *batchRequest))success
                              failure:(nullable void (^)(HYDBatchRequest *batchRequest))failure;

    ///  Nil out both success and failure callback blocks.
- (void)clearCompletionBlock;

    ///  Append all the requests to queue.
- (void)start;

    ///  Stop all the requests of the batch request.
- (void)stop;

    ///  Convenience method to start the batch request with block callbacks.
- (void)startWithCompletionBlockWithSuccess:(nullable void (^)(HYDBatchRequest *batchRequest))success
                                    failure:(nullable void (^)(HYDBatchRequest *batchRequest))failure;

@end

NS_ASSUME_NONNULL_END
