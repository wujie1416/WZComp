//
//  ApiHttpRequestUtil+Upload.m
//  AFNetworking
//
//  Created by cheyueyong on 2018/1/30.
//

#import "ApiHttpRequestUtil+Upload.h"
#import "WZURLSessionWrapperOperation.h"

@implementation ApiHttpRequestUtil (Upload)


#define kMaxConcurrentOperationCount 9

- (NSOperationQueue *)uploadImagesWithOperation:(NSString *)uploadUrl
                                         images:(NSArray <UIImage *> *)images
                                     imageNames:(NSArray <NSString *> *)imageNames
                                        success:(ApiUploadSuccessCallBack)success
                                           fail:(ApiUploadFailCallBack)fail
{
    NSAssert(images.count == imageNames.count, @"the number of image and the number of iamgename must be equal!");
    
    // 准备保存结果的数组，元素个数与上传的图片个数相同，先用 NSNull 占位
    NSMutableArray *resResults = [NSMutableArray array];
    for (NSInteger i=0; i < images.count; i++) {
        [resResults addObject:[NSNull null]];
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = kMaxConcurrentOperationCount;
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        // 延时0.1s，等待最后一个operation的completionHandler处理完毕数据，然后回到主线程执行，方便更新 UI 等
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            WZLogInfo(@"upload images to %@ with operation finished!", uploadUrl);
            if(success) success(resResults);
        });
    }];
    
    for (NSInteger i = 0; i < images.count; i++) {
        
        NSURLRequest *request = [[APIRequestGenerator sharedInstance] generateUpLoadRequestWithUrl:uploadUrl constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            NSData* imageData = UIImageJPEGRepresentation(images[i], 0.1);
            [formData appendPartWithFileData:imageData name:@"file" fileName:imageNames[i]?:@"noName" mimeType:@"multipart/form-data"];
        }];
        self.timeoutSeconds = self.timeoutSeconds*2;
        AFSecurityPolicy * policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        policy.allowInvalidCertificates = YES;
        policy.validatesDomainName = NO;
        self.sessionManager.securityPolicy = policy;
        __block NSURLSessionUploadTask *uploadTask = [self.sessionManager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (error) {
                WZLogError(@"##########response request.URL: %@ for %@ and upload %ld file failed error is %@", uploadUrl, self.requestDelegate, i, error);
                if (fail) fail(response, error);
            } else {
                APIURLResponse *urlResponse = [[APIURLResponse alloc] initWithNoDESResponseData:responseObject error:nil requestId:@(uploadTask.taskIdentifier)];
                WZLogInfo(@"##########response request.URL: %@ for %@ and upload %ld file successed data is %@", uploadUrl, self.requestDelegate, i, urlResponse.content);
                @synchronized (resResults) { //NSMutableArray 是线程不安全的，所以加个同步锁
                    resResults[i] = urlResponse.content;
                }
            }
        }];
        
        WZURLSessionWrapperOperation *uploadOperation = [WZURLSessionWrapperOperation operationWithURLSessionTask:uploadTask];
        [completionOperation addDependency:uploadOperation];
        [queue addOperation:uploadOperation];
    }
    
    [queue addOperation:completionOperation];
    return queue;
}



- (NSURLSessionDataTask *)uploadImageWithAFNRequestUrl:(NSString *)url
                                              fileData:(NSData *)fileData
                                                  name:(NSString *)name
                                               success:(ApiHTTPRequestCallBack)success
                                                  fail:(ApiHTTPRequestCallBack)fail
                                              progress:(ApiHTTPRequestUploadCallBack)flieUploadProgress
{
    return [self uploadApiWithAFNRequestUrl:url fileData:fileData name:name mimeType:@"image/png" success:success fail:fail progress:flieUploadProgress];
}



- (NSURLSessionDataTask *)uploadApiWithAFNRequestUrl:(NSString *)url
                                            fileData:(NSData *)fileData
                                                name:(NSString *)name
                                            mimeType:(NSString *)mimeType
                                             success:(ApiHTTPRequestCallBack)success
                                                fail:(ApiHTTPRequestCallBack)fail
                                            progress:(ApiHTTPRequestUploadCallBack)flieUploadProgress
{
    if (fileData == nil) {
        if (fail) fail([[NSError alloc] initWithDomain:kErrorDomain code:APIManagerErrorTypeParamsError userInfo:@{@"failReason":@"上传文件的元数据为空！"}], nil);
        return nil;
    }
    NSURLRequest *request = [[APIRequestGenerator sharedInstance] generateUpLoadRequestWithUrl:url constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:@"file" fileName:name mimeType:mimeType];
    }];
    self.timeoutSeconds = self.timeoutSeconds*2;
    self.sessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    __block NSURLSessionUploadTask *task = [self.sessionManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        if (flieUploadProgress) flieUploadProgress(uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            WZLogError(@"##########response request.URL: %@ for %@ and error is %@", url, self.requestDelegate, error);
            if (fail) fail(error, task.currentRequest);
        } else {
            APIURLResponse *urlResponse = [[APIURLResponse alloc] initWithNoDESResponseData:responseObject error:nil requestId:@(task.taskIdentifier)];
            WZLogInfo(@"##########response request.URL: %@ for %@ and data is %@", url, self.requestDelegate, urlResponse.content);
            success(urlResponse, task.currentRequest);
        }
    }];
    [task resume];
    return task;
}

@end
