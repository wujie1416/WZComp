//
//  VoiceCheckGetVoiceStatusManager.h
//  AFNetworking
//
//  Created by wujie on 2018/5/24.
//

#import "HYDBaseRequestManager.h"

/**
 查询用户声纹状态
 http://118.26.170.236/pages/viewpage.action?pageId=13184897
 */
@interface VoiceCheckGetVoiceStatusManager : HYDBaseRequestManager
//出参
@property (nonatomic, copy) NSString *valid;
@property (nonatomic, copy) NSString *describ;
@property (nonatomic, copy) NSString *uploadTime;

@property (nonatomic, copy) NSString *ymdStr;//年月日
@property (nonatomic, copy) NSString *hmsStr;//时分秒
@end
/**
 "valid"： "2"不合格 ； "1"审核通过 ； "0" 检测中 ；"3"用户没有做声纹认证；
 "describ"：回调结果描述
 "uploadTime":文件上传完毕时间
 */
