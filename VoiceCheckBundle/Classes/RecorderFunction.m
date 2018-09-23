//
//  RecorderFunction.m
//  AFNetworking
//
//  Created by wujie on 2018/5/23.
//

#import "RecorderFunction.h"
#import <AVFoundation/AVFoundation.h>

#define kRecordAudioFile @"ios_luyin.wav"

@interface RecorderFunction()<AVAudioRecorderDelegate ,AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) BOOL isPlay;
@end

@implementation RecorderFunction

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setAudioSessionCategoryPlayAndRecord];
    }
    return self;
}

//在开始录音前，要把会话方式设置成AVAudioSessionCategoryPlayAndRecord
- (void)setAudioSessionCategoryPlayAndRecord
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    //听筒模式
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&setCategoryError];
    NSError *activationError = nil;
    [session setActive:YES error:&activationError];
}

//在开始录音前，要把会话方式设置成AVAudioSessionCategoryPlayAndRecord
- (void)setAudioSessionCategoryPlayback
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    //扬声器模式
    [session setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    NSError *activationError = nil;
    [session setActive:YES error:&activationError];
}

//创建AVAudioRecorder 给出录音存放的地址，录音的设置等
- (NSURL *)getRecordAudioPath
{
    return [[NSURL alloc] initFileURLWithPath:[self getSavePath]];
}

- (NSString *)getSavePath
{
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr = [urlStr stringByAppendingPathComponent:kRecordAudioFile];//路径拼接
    NSLog(@"file path:%@",urlStr);
    return urlStr;
}

- (void)removeRecordData
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[self getSavePath]]) {
        [fm removeItemAtPath:[self getSavePath] error:nil];
    }
}

- (NSData *)getAudioData
{
    return [NSData dataWithContentsOfURL:[self getRecordAudioPath]];
}

//开始录音
- (void)startRecord
{
    [self setAudioSessionCategoryPlayAndRecord];
    [self.audioRecorder record];
}

//暂停录音
- (void)pauseRecord
{
    [self.audioRecorder pause];
}

//停止录音
- (void)stopRecord
{
    [self.audioRecorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"录音完成!");
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error
{
    NSLog(@"录音出错!");
}


//开始播放
- (void)startPlay
{
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self getRecordAudioPath] error:nil];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    self.audioPlayer.numberOfLoops = 0;
    [self setAudioSessionCategoryPlayback];
    self.audioPlayer.currentTime = 0.0;
    [self.audioPlayer play];
}

//停止播放
- (void)stopPlay
{
    [self.audioPlayer stop];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"player:%@ 播放完成%d",player,flag);
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    NSLog(@"player 播放失败%@",error);
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
- (NSDictionary *)getAudioSetting
{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    dicM = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
            [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
            [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
            [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
            [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
            [NSNumber numberWithInt: AVAudioQualityLow],AVEncoderAudioQualityKey,//音频编码质量
            nil];
    return dicM;
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
- (AVAudioRecorder *)audioRecorder
{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url = [self getRecordAudioPath];
        //创建录音格式设置
        NSDictionary *setting = [self getAudioSetting];
        //创建录音机
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
        [_audioRecorder prepareToRecord];
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

@end
