//
//  WZLogging.h
//
//  Created by cheyy on 16/3/29.
//  Copyright © 2016年 Subao Technology. All rights reserved.
//

#import "WZLogger.h"


#ifndef WZLogging_h
#define WZLogging_h

#define WZLogDebug(frmt, ...) \
[[WZLogger sharedLogger] logMessageWithLevel:WZLogLevel_DEBUG tag:0 format:(frmt), ##__VA_ARGS__]

#define WZLogInfo(frmt, ...) \
[[WZLogger sharedLogger] logMessageWithLevel:WZLogLevel_INFO tag:0 format:(frmt), ##__VA_ARGS__]
//fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:frmt, ##__VA_ARGS__] UTF8String]);

#define WZLogWarning(frmt, ...) \
[[WZLogger sharedLogger] logMessageWithLevel:WZLogLevel_WARNING tag:0 format:(frmt), ##__VA_ARGS__]

#define WZLogError(frmt, ...) \
[[WZLogger sharedLogger] logMessageWithLevel:WZLogLevel_ERROR tag:0 format:(frmt), ##__VA_ARGS__]


#endif /* WZLogging_h */
