//
//  RecorderFunction.h
//  AFNetworking
//
//  Created by wujie on 2018/5/23.
//

#import <Foundation/Foundation.h>

@interface RecorderFunction : NSObject

//开始录音
- (void)startRecord;

//暂停录音
- (void)pauseRecord;

//停止录音
- (void)stopRecord;

//开始播放
- (void)startPlay;

//停止播放
- (void)stopPlay;

//获取本地的录音文件
- (NSData *)getAudioData;

//删除录音文件
- (void)removeRecordData;
@end
