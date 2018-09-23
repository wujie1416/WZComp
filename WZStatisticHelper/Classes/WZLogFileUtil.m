//
//  WZLogFileUtil.m
//  HC-HYD
//
//  Created by 老司机车 on 2017/7/18.
//  Copyright © 2017年 cheyy. All rights reserved.
//

#import "WZLogFileUtil.h"
#import "HYDNetWork.h"
#import "HYDLSUserManager.h"
#import <zlib.h>
#import <zconf.h>

@interface WZLogFileUtil()
@property(nonatomic, strong) ApiHttpRequestUtil *getUrlReqUtil;
@property(nonatomic, strong) ApiHttpRequestUtil *uploadReqUtil;
@property(nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation WZLogFileUtil

static  WZLogFileUtil *g_uploadFileInstatance = nil;

+ (WZLogFileUtil *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_uploadFileInstatance = [[WZLogFileUtil alloc] init];
        g_uploadFileInstatance.semaphore = dispatch_semaphore_create(1);
    });
    return g_uploadFileInstatance;
}

+ (void)upload;
{
    dispatch_semaphore_wait([self shared].semaphore, DISPATCH_TIME_FOREVER);
    if ([WZLogger getLogFileTotalSize] < 1024*1024*1) { //小于1MB不上传,测算1MB整体压缩完应该在80KB左右
        dispatch_semaphore_signal([self shared].semaphore);
        return;
    }
    [[self shared] startGetUploadLogUrlReqUtil];
}

+ (void)uploadWithIgnoreSize
{
    dispatch_semaphore_wait([self shared].semaphore, DISPATCH_TIME_FOREVER);
    if ([WZLogger getLogFileTotalSize] < 1024*2) { //小于2k不上传
        dispatch_semaphore_signal([self shared].semaphore);
        return;
    }
    [[self shared] startGetUploadLogUrlReqUtil];
}

#pragma mark -- private

- (void)reportUploadedUrl:(NSString *)url
{
    //http://10.150.20.110/pages/viewpage.action?pageId=7668188
    ApiHttpRequestUtil *requestUtil = [[ApiHttpRequestUtil alloc] init];
    NSDictionary *param = @{@"type":@"behaviour",
                                                @"location":url,
                                                @"osType":@"ios",
                                                @"osVersion":[UIDevice currentDevice].systemVersion,
                                                @"appType":@"hyd",
                                                @"appVersion":[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                                @"downloadChannel":@"201"};
    [requestUtil callPOSTWithParams:param methodName:@"/jsd/app/logFile/reportMetaInfo" serviceType:ServiceTypeJsd success:^(id response, NSURLRequest *request) {
        WZLogInfo(@"upload user  operation log file  success!");
         [WZLogger deleteAllLocalLogFile];
        dispatch_semaphore_signal(self.semaphore);
    } fail:^(id response, NSURLRequest *request) {
        [self deleteLocalZipFile];
        dispatch_semaphore_signal(self.semaphore);
    }];
}
- (void)deleteLocalZipFile
{
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[WZLogger getLogsDirectory] error:nil];
    for (NSString *fileName in fileNames) {
        if ([fileName containsString:@".zip"]) {
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",[WZLogger getLogsDirectory], fileName] error:nil];
        }
    }
}

- (void)startGetUploadLogUrlReqUtil
{
    __weak __typeof(&*self)weakSelf = self;
    NSDictionary *param = @{@"category": @"log", @"apiVersion":@"ver2"};
    [self.getUrlReqUtil callPOSTWithParams:param methodName:@"/jsd/app/fileUpload/getUploadUrl" serviceType:ServiceTypeJsd success:^(id response, NSURLRequest *request) {
        APIURLResponse *urlResponse = (APIURLResponse *)response;
        NSDictionary *outputDict = (NSDictionary *)urlResponse.content;
        if ([outputDict[@"status"] integerValue] == 200) {
            NSString *upUrl = outputDict[@"data"][@"url"];
            [weakSelf startUploadReqUtilWithUrl:upUrl];
        } else {
            dispatch_semaphore_signal(weakSelf.semaphore);
        }
    } fail:^(id response, NSURLRequest *request) {
        dispatch_semaphore_signal(weakSelf.semaphore);
    }];
}

- (void)printAllFileInDirectory:(NSString *)directory
{
    NSString *path=nil;
    NSDirectoryEnumerator *myDirectoryEnumerator=[[NSFileManager defaultManager] enumeratorAtPath:directory];
    WZLogInfo(@"用enumeratorAtPath:显示目录%@的内容：",directory);
    while((path=[myDirectoryEnumerator nextObject])!=nil) WZLogInfo(@"%@",path);
}

- (NSData *)getNeedZipOriginData
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpPath = [[WZLogger getLogsDirectory] stringByAppendingPathComponent:@"tmp.log"];
    BOOL ret = [fileManager createFileAtPath:tmpPath contents:nil attributes:nil];
    if (ret == NO) {
        return nil;
    }
    NSString *totalDataStr = @"";
    NSMutableArray *allFiles = [NSMutableArray arrayWithArray:[WZLogger sortedLogFilePaths]];
    for (NSInteger i = allFiles.count-1; i >= 0; i--) {
        NSString *subDataStr = [NSString stringWithContentsOfFile:allFiles[i] encoding:NSUTF8StringEncoding error:nil];
        if (subDataStr == nil) {
            continue;
        }
        totalDataStr = [totalDataStr stringByAppendingString:subDataStr];
        [totalDataStr writeToFile:tmpPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    NSData *originData = [NSData dataWithContentsOfFile:tmpPath];
    [fileManager removeItemAtPath:tmpPath error:nil];
    return originData;
}

- (void)startUploadReqUtilWithUrl:(NSString *)url
{
    if (url || url.length == 0) {
        dispatch_semaphore_signal(self.semaphore);
        return;
    }
    __weak __typeof(&*self)weakSelf = self;
    NSString *filename = [NSString stringWithFormat:@"%@_%ld.zip", HYDUserModelManagerShared.userModel.userId, (long)[[NSDate date] timeIntervalSince1970]];
    [WZLogger rollLogFileWithCompletionBlock:^{
        
        NSData *originData = [weakSelf getNeedZipOriginData];
        if (originData == nil) {
            dispatch_semaphore_signal(self.semaphore);
            return;
        }
        NSString *deviceCode = [[APIRequestGenerator sharedInstance].commonParams objectForKey:@"deviceCode"];
        NSString *zipPath = [NSString stringWithFormat:@"%@/%@_%ld.zip",[WZLogger getLogsDirectory],deviceCode, (long)[[NSDate date] timeIntervalSince1970]];
        [[NSFileManager defaultManager] createFileAtPath:zipPath contents:[weakSelf gzipDeflate:originData] attributes:nil];
 
        if (![[NSFileManager defaultManager] fileExistsAtPath:zipPath]) {
            dispatch_semaphore_signal(self.semaphore);
            return;
        }
        
        [weakSelf.uploadReqUtil uploadApiWithAFNRequestUrl:url fileData: [NSData dataWithContentsOfFile:zipPath] name:filename mimeType:@"text/plain" success:^(id response, NSURLRequest *request) {
            APIURLResponse *urlResponse = (APIURLResponse *)response;
            NSDictionary *outputDict = urlResponse.content;
            NSArray *arr = outputDict[@"fileItemInfos"];
            if ([outputDict[@"status"] integerValue] == 200 && arr.count > 0) {
                [weakSelf reportUploadedUrl:[arr[0] objectForKey:@"location"]];
            } else {
                WZLogError(@"upload file zip failed and response is : %@", urlResponse);
                [weakSelf deleteLocalZipFile];
                dispatch_semaphore_signal(weakSelf.semaphore);
            }
        } fail:^(id response, NSURLRequest *request) {
            WZLogError(@"upload file zip failed and response is : %@", response);
            [weakSelf deleteLocalZipFile];
            dispatch_semaphore_signal(weakSelf.semaphore);
        } progress:nil];
    }];
}
#pragma mark - zipFunc

//压缩
- (NSData *)gzipDeflate:(NSData*)data
{
    if ([data length] == 0) return data;
    z_stream strm;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[data bytes];
    strm.avail_in = (uInt)[data length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    do {
        if (strm.total_out >= [compressed length]) [compressed increaseLengthBy:16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([compressed length] - strm.total_out);
        deflate(&strm, Z_FINISH);
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}

//解压缩
- (NSData *)gzipInflate:(NSData*)data
{
    if ([data length] == 0) return data;
    
    unsigned long full_length = [data length];
    unsigned long  half_length = [data length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = (uInt)[data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK)
        return nil;
    
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([decompressed length] - strm.total_out);
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END)
            done = YES;
        else if (status != Z_OK)
            break;
    }
    if (inflateEnd (&strm) != Z_OK)
        return nil;
    
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}



#pragma mark - getter
- (ApiHttpRequestUtil *)getUrlReqUtil
{
    if (!_getUrlReqUtil) {
        _getUrlReqUtil = [[ApiHttpRequestUtil alloc] init];
    }
    return _getUrlReqUtil;
}

- (ApiHttpRequestUtil *)uploadReqUtil
{
    if (!_uploadReqUtil) {
        _uploadReqUtil = [[ApiHttpRequestUtil alloc] init];
    }
    return _uploadReqUtil;
}
@end
