//
//  WZLogger.m
//
//  Created by cheyy on 16/3/29.
//  Copyright © 2016年 Subao Technology. All rights reserved.
//

#import "WZLogger.h"
#import "CocoaLumberjack.h"
#include <syslog.h>
#include <stdarg.h>

#ifdef DEBUG
static const int ddLogLevel = DDLogLevelVerbose;
#else
static const int ddLogLevel = DDLogLevelError;
#endif

@implementation WZLogger {
    NSDateFormatter *threadUnsafeDateFormatter;
}

///--------------------------------------
#pragma mark - Init
///--------------------------------------
+ (void)load
{
    NSString *initMsg = [NSString stringWithFormat:@"app(%@) start and init log lib !", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]];
    [[WZLogger sharedLogger] output:WZLogLevel_INFO message:initMsg];
}
    
- (id)init {
    if((self = [super init])) {
        threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
        [threadUnsafeDateFormatter setDateFormat:@"HH:mm:ss"];
    }
    return self;
}

+ (instancetype)sharedLogger {
    static WZLogger *logger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[WZLogger alloc] init];
        logger.logLevel = WZLogLevel_INFO;
        
        DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
        [fileLogger setMaximumFileSize:(1024 * 1024)];
        [fileLogger setRollingFrequency:0];
        [fileLogger.logFileManager setMaximumNumberOfLogFiles:0];
        [DDLog addLogger:fileLogger withLevel:DDLogLevelError];
        
//        DDTTYLogger *ttyLogger = [DDTTYLogger sharedInstance];
//        ttyLogger.automaticallyAppendNewlineForCustomFormatters = YES;
//        [DDLog addLogger:ttyLogger withLevel:DDLogLevelAll];
        
    });
    return logger;
}

- (void)logMessageWithLevel:(int)level
                        tag:(int)tag
                     format:(NSString *)format, ... {
    if (level < self.logLevel || self.logLevel == WZLogLevel_None) {
#ifndef  DEBUG
        return;
#endif
    }
    va_list args;
    va_start(args, format);
    NSMutableString *message = [[NSMutableString alloc] init];
    [message appendFormat:@": %@", format];
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
//    NSLogv(message, args);
    va_end(args);
    
    [self output:level message:str];
}

- (void)output:(int)level message:(NSString *)message
{
    if ([UIApplication sharedApplication].keyWindow == nil && ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0)) {
        return; //iOS8在+load中打印日志会导致app卡死
    }
    NSString *logLevel = nil;
    switch (level) {
        case WZLogLevel_ERROR:
            logLevel = @"E😡";
            break;
        case WZLogLevel_WARNING:
            logLevel = @"W😭";
            break;
        case WZLogLevel_INFO:
            logLevel = @"I😃";
            break;
        case WZLogLevel_DEBUG:
            logLevel = @"D🙃";
            break;
        default:
            logLevel = @"V😜";
            break;
    }
    
    NSString *dateAndTime = [threadUnsafeDateFormatter stringFromDate:[NSDate date]];
    syslog(LOG_WARNING, "%s [%s] [%s]> %s\n", [dateAndTime UTF8String], [logLevel UTF8String], [@"iOS_HYD" UTF8String], [message UTF8String]);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        printf("\n%s [%s] [%s]> %s\n", [dateAndTime UTF8String], [logLevel UTF8String], [@"iOS_HYD" UTF8String], [message UTF8String]);
    }
    DDLogError(@" [%@]> %@$",  @"iOS_HYD", message);
}

+ (CGFloat)getLogFileTotalSize
{
    CGFloat totalFilesize = 0;
    DDFileLogger *fileLogger = [DDLog allLoggers][0];
    NSArray *logInfos = fileLogger.logFileManager.unsortedLogFileInfos;
    for (DDLogFileInfo *logFileInfo in logInfos) {
        totalFilesize += logFileInfo.fileSize;
    }
    return totalFilesize;
}
    
+ (void)deleteAllLocalLogFile
{
    NSArray *array = [DDLog allLoggers];
    DDFileLogger *fileLogger = array[0];
    NSError *error = NULL;
    BOOL ret = [[NSFileManager defaultManager] removeItemAtPath:fileLogger.logFileManager.logsDirectory error:&error];
    if (ret && !error) {
        [[WZLogger sharedLogger] output:WZLogLevel_INFO message:@"delete local  log file success!"];
    } else {
        [[WZLogger sharedLogger] output:WZLogLevel_ERROR message:@"delete local  log file failed!"];
    }
}
    
+ (NSString *)getLogsDirectory
{
    DDFileLogger *fileLogger = [DDLog allLoggers][0];
    return fileLogger.logFileManager.logsDirectory;
}

+ (NSArray<NSString *> *)sortedLogMsgByRows
{
    NSMutableArray *totalMuArray = [NSMutableArray arrayWithCapacity:0];
    for (NSString *filePath in [WZLogger sortedLogFilePaths]) {
        NSString *logString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
        if (logString && logString.length > 0) {
            NSArray *subArray = [logString componentsSeparatedByString:@"$"];
            NSMutableArray *mSubArray=[NSMutableArray arrayWithArray:[[subArray reverseObjectEnumerator] allObjects]];
            [mSubArray removeObjectAtIndex:0];
            [totalMuArray addObjectsFromArray:mSubArray];
        }
    }
    return totalMuArray;
}
    
+ (NSArray<NSString *> *)sortedLogFilePaths
{
    [DDLog flushLog];
    DDFileLogger *fileLogger = [DDLog allLoggers][0];
    return  fileLogger.logFileManager.sortedLogFilePaths;
}
    
    
+ (void)rollLogFileWithCompletionBlock:(void (^)(void))completionBlock
{
    DDFileLogger *fileLogger = [DDLog allLoggers][0];
    [fileLogger rollLogFileWithCompletionBlock:completionBlock];
}
    

@end
