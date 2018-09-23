//
//  RecorderViewController.m
//  AFNetworking
//
//  Created by wujie on 2018/5/18.
//

#import "RecorderViewController.h"
#import "UtilsMacro.h"
#import "BusMacro.h"
#import "RecorderView.h"
#import "RecorderFunction.h"
#import <AFNetworking.h>
#import "MBProgressHUD+WZ.h"
#import "VoiceCheckGetReadContentManager.h"
#import "VoiceCheckNoticeUploadManager.h"
#import "HYDLSUserManager.h"
#import "VoiceCheckgetUploadUrlManager.h"
#import "YYKit.h"

#define kRecordAudioFile @"ios_luyin.wav"

@interface RecorderViewController () <RecorderViewDelegate,HYDBaseRequestManagerCallBackDelegate>
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) RecorderFunction *recorderFunction;
@property (nonatomic, strong) RecorderView *recorderView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *playTimer;
@property (nonatomic, strong) VoiceCheckGetReadContentManager *getReadContentManager;
@property (nonatomic, strong) VoiceCheckNoticeUploadManager *noticeUploadManager;
@property (nonatomic, strong) VoiceCheckgetUploadUrlManager *getUploadUrlManager;
@property (nonatomic, assign) NSInteger recordProgress;
@property (nonatomic, assign) BOOL hasPlayed;
@end

@implementation RecorderViewController
{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"声纹采集";
    self.view.backgroundColor = UIColorFromRGB(0x000000);
    [self.view addSubview:self.recorderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configNavBarWithFont:kFont(17) foregroundColor:UIColorFromRGB(0xFFFFFF) bgColor:UIColorFromRGB(0x000000)];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.getReadContentManager startTask];
}

- (void)manager:(HYDBaseRequestManager *)manager didSuccessWithResponse:(APIURLResponse *)response
{
    if (manager == self.getReadContentManager) {
        self.recorderView.timeLength = self.getReadContentManager.maxTime;
        self.recorderView.text = self.getReadContentManager.content;
        self.recorderView.dateLabel.text = self.getReadContentManager.dataStr;
        self.recorderView.titleLabel.text = [NSString stringWithFormat:@"请朗读文字并录音，录音时长不可低于%ld秒。",(long)self.getReadContentManager.minTime];
    } else if (manager == self.getUploadUrlManager) {
        [self uploadFormDataWithUrl:self.getUploadUrlManager.url];
    } else if (manager == self.noticeUploadManager) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)manager:(HYDBaseRequestManager *)manager didFailedWithError:(NSError *)error
{
    [MBProgressHUD showMessage:manager.retModel.showMsg];
}

//点击播放按钮
- (void)playButtonClick
{
    if (self.recorderView.playButton.selected) {
        //播放中点击暂停
        [self.recorderFunction stopPlay];
        [self.playTimer setFireDate:[NSDate distantFuture]];
        //录音按钮可以点击
        [self.recorderView.recordButton setEnabled:YES];
        [self.recorderView.commitButton setEnabled:YES];
    } else {
        //暂停时点击播放
        self.hasPlayed = YES;
        [self.recorderFunction stopRecord];
        [self.recorderFunction startPlay];
        self.recorderView.playSecond = 0;
        [self.playTimer setFireDate:[NSDate distantPast]];
        [self.recorderView.recordButton setEnabled:NO];
        [self.recorderView.commitButton setEnabled:NO];
    }
    self.recorderView.playButton.selected = !self.recorderView.playButton.selected;
}

//点击录音按钮
- (void)recordButtonClick
{
    if (self.recorderView.recordButton.selected) {//正在录音
        if (self.recorderView.second > (long)self.getReadContentManager.minTime * 60) {//可以暂停
            [self.timer setFireDate:[NSDate distantFuture]];//暂停录音
            [self.recorderFunction pauseRecord];
            [self.recorderView.playButton setEnabled:YES];
            [self.recorderView.commitButton setEnabled:YES];
            self.recorderView.recordButton.selected = !self.recorderView.recordButton.selected;
        } else {
            NSString *str = [NSString stringWithFormat:@"声纹时长不能小于%lds",(long)self.getReadContentManager.minTime];
            [MBProgressHUD showMessage:str];
        }
    } else {//默认静止状态
        self.recorderView.recordButton.selected = !self.recorderView.recordButton.selected;
        if (self.hasPlayed) {
            //播放过删除重新录
            self.hasPlayed = NO;
            self.recorderView.second = 0.0;
            [self.recorderFunction removeRecordData];
            [self.recorderFunction startRecord];
            [self.timer setFireDate:[NSDate distantPast]];
            [self.recorderView.playButton setEnabled:NO];
            [self.recorderView.commitButton setEnabled:NO];
        } if (self.recorderView.second >= 3600) {
            //自动录完以后点击重新录
            self.recorderView.second = 0.0;
            [self.recorderView.playButton setEnabled:NO];
            [self.recorderView.commitButton setEnabled:NO];
            [self.recorderFunction removeRecordData];
            [self.recorderFunction startRecord];
            [self.timer setFireDate:[NSDate distantPast]];
        } else {
            //继续录或者是刚开始录
            [self.recorderView.playButton setEnabled:NO];
            [self.recorderView.commitButton setEnabled:NO];
            [self.recorderFunction startRecord];
            [self.timer setFireDate:[NSDate distantPast]];
        }
    }
}

//点击提交按钮
- (void)commitButtonClick
{
    [self addAlertController];
}

//弹出提示框
- (void)addAlertController
{
    if (@available(iOS 8.0, *)) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"录音提交后不可修改，确定提交吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"再听听" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *commitAction = [UIAlertAction actionWithTitle:@"立即提交" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.recorderFunction stopRecord];
            [self.getUploadUrlManager startTask];
        }];
        [cancelAction setValue:UIColorFromRGB(0x666666) forKey:@"_titleTextColor"];
        [commitAction setValue:UIColorFromRGB(0x10A8EA) forKey:@"_titleTextColor"];
        [alertController addAction:cancelAction];
        [alertController addAction:commitAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)uploadFormDataWithUrl:(NSString *)url
{
    [self.sessionManager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = [self.recorderFunction getAudioData];
        //上传数据:FileData-->data name-->fileName(固定，和服务器一致) fileName-->你的语音文件名 mimeType-->我的语音文件type是audio/wav 如果你是图片可能为image/png
        NSString *fileName = @"wav";
        NSString *name = kRecordAudioFile;
        NSString *type = @"audio/wav";
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:type];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        int statusCode = [[responseObject objectForKey:@"status"] intValue];
        if (statusCode == 200) {
            NSArray *dicArray = [responseObject objectForKey:@"fileItemInfos"];
            NSDictionary * fileItemInfos = dicArray[0];
            //通知研究院有文件上传
            self.noticeUploadManager.audioUrl = [fileItemInfos stringValueForKey:@"location" default:@""];
            self.noticeUploadManager.audioId =[fileItemInfos stringValueForKey:@"id" default:@""];
            self.noticeUploadManager.textId = self.getReadContentManager.contentId;
            self.noticeUploadManager.crmId = HYDUserModelManagerShared.userModel.userId;
            self.noticeUploadManager.date = [NSDate date];
            [self.noticeUploadManager startTask];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD showMessage:@"上传失败"];
    }];
}

//录音定时器方法
- (void)startTimer
{
    self.recorderView.second += 1;
    if (self.recorderView.second >= self.getReadContentManager.maxTime * 60) {
        [self.recorderFunction stopRecord];
        self.recorderView.recordButton.selected = !self.recorderView.recordButton.selected;
        [self.recorderView.playButton setEnabled:YES];
        [self.recorderView.commitButton setEnabled:YES];
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

//播放定时器方法
- (void)startPlayTimer
{
    self.recorderView.playSecond += 1;
    if (self.recorderView.playSecond >= self.recorderView.second) {
        self.recorderView.playButton.selected = !self.recorderView.playButton.selected;
        [self.recorderView.recordButton setEnabled:YES];
        [self.playTimer invalidate];
        self.playTimer = nil;
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
    [self.playTimer invalidate];
    self.playTimer = nil;
}

- (RecorderFunction *)recorderFunction
{
    if (!_recorderFunction) {
        _recorderFunction = [[RecorderFunction alloc] init];
    }
    return _recorderFunction;
}

- (RecorderView *)recorderView
{
    if (!_recorderView) {
        _recorderView = [[RecorderView alloc] initWithFrame:self.view.frame];
        _recorderView.delegate = self;
    }
    return _recorderView;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 / 60.0 target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (NSTimer *)playTimer
{
    if (!_playTimer) {
        _playTimer = [NSTimer scheduledTimerWithTimeInterval:1 / 60.0 target:self selector:@selector(startPlayTimer) userInfo:nil repeats:YES];
    }
    return _playTimer;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain",nil];
        _sessionManager.requestSerializer.timeoutInterval = 20;
    }
    return _sessionManager;
}

- (VoiceCheckGetReadContentManager *)getReadContentManager
{
    if (!_getReadContentManager) {
        _getReadContentManager = [[VoiceCheckGetReadContentManager alloc] initWithCallBackDelegate:self];
        _getReadContentManager.userName = [HYDLSUserManager defaultUserManager].userModel.userName;
    }
    return _getReadContentManager;
}

- (VoiceCheckNoticeUploadManager *)noticeUploadManager
{
    if (!_noticeUploadManager) {
        _noticeUploadManager = [[VoiceCheckNoticeUploadManager alloc] initWithCallBackDelegate:self];
    }
    return _noticeUploadManager;
}

- (VoiceCheckgetUploadUrlManager *)getUploadUrlManager
{
    if (!_getUploadUrlManager) {
        _getUploadUrlManager = [[VoiceCheckgetUploadUrlManager alloc] initWithCallBackDelegate:self];
        _getUploadUrlManager.userId = HYDUserModelManagerShared.userModel.userId;
    }
    return _getUploadUrlManager;
}

@end
