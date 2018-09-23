//
//  WZLogger.h
//
//  Created by cheyy on 16/3/29.
//  Copyright © 2016年 Subao Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, WZLogLevel) {
    WZLogLevel_None = 0,
    WZLogLevel_DEBUG = 1,
    WZLogLevel_INFO = 2,
    WZLogLevel_WARNING = 3,
    WZLogLevel_ERROR = 4
};

@interface WZLogger : NSObject

@property (atomic) int logLevel;

+ (instancetype)sharedLogger;

///--------------------------------------
#pragma mark - Logging Messages
///--------------------------------------

/**
 Logs a message at a specific level for a tag.
 If current logging level doesn't include this level - this method does nothing.
 
 @param level  Logging Level
 @param tag    Logging Tag
 @param format Format to use for the log message.
 */
- (void)logMessageWithLevel:(int)level
                        tag:(int)tag
                     format:(NSString *)format, ... ;
- (void)output:(int)level message:(NSString *)message;
    

/**
     获取打印的本地日志文件的总大小
 */
+ (CGFloat)getLogFileTotalSize;
  
/**
   删除所有的本地日志文件
*/
+ (void)deleteAllLocalLogFile;

    
/**
     获取存储本地日志的文件夹路径
 */
+ (NSString *)getLogsDirectory;

/**
     按照打印时间获取每一行日志信息（最新的在最前面）
 */
+ (NSArray<NSString *> *)sortedLogMsgByRows;
    
/**
 * The items in the array are sorted by creation date.
 * The first item in the array will be the most recently created log file.
 */
+ (NSArray<NSString *> *)sortedLogFilePaths;
    
/**
 *  You can optionally force the current log file to be rolled with this method.
 *  CompletionBlock will be called on main queue.
 */
+ (void)rollLogFileWithCompletionBlock:(void (^)(void))completionBlock NS_SWIFT_NAME(rollLogFile(withCompletion:));
    

@end





