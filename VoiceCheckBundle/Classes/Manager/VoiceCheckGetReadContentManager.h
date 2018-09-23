//
//  VoiceCheckGetReadContentManager.h
//  AFNetworking
//
//  Created by wujie on 2018/5/24.
//

#import "HYDBaseRequestManager.h"

/**
 http://118.26.170.236/pages/viewpage.action?pageId=13184879
 获得阅读内容,内容id,以及时间限制
 */
@interface VoiceCheckGetReadContentManager : HYDBaseRequestManager
//入参
@property (nonatomic, copy) NSString *userName;
//出参
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *contentId;
@property (nonatomic, assign) NSInteger minTime;
@property (nonatomic, assign) NSInteger maxTime;
@property (nonatomic, copy) NSString *dataStr;
@end
/**
 {
 "rspCode": 200 401 500
 "rspMsg": "访问成功！",
 "showMsg": "访问成功！"，
 "data": {
 "content": "OK，恒昌，我是张三，今天2018年4月12日，现在开始录音，这也是鼓励民间资本民间人士兴办教育，政府主要是把好准入，这是一件很有意义的事情，",   // 返回的阅读文字字符串
 "id": 188，           //返回的阅读文字的id
 "minTime":”30”,       //最短录音时长
 "maxTime":”60”,      //最大录音时长
 }
 }
 */
