//
//  VoiceCheckNoticeUploadManager.h
//  AFNetworking
//
//  Created by wujie on 2018/5/24.
//

#import "HYDBaseRequestManager.h"

/**
 声纹识别--通知研究院有文件上传
 http://118.26.170.236/pages/viewpage.action?pageId=13184894
 */
@interface VoiceCheckNoticeUploadManager : HYDBaseRequestManager
/**
 入参
 audioId s3存储服务器上的文件id
 audioUrl s3存储服务器上对应文件的url
 textId  该文件对应的阅读文本id
 crmId  用户id（就是userId）
 loanId  进件id，预留 (非必填)
 date  文件上传时间
 */
@property (nonatomic, copy) NSString *audioId;
@property (nonatomic, copy) NSString *audioUrl;
@property (nonatomic, copy) NSString *textId;
@property (nonatomic, copy) NSString *crmId;
@property (nonatomic, strong) NSDate *date;
@end

