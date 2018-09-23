//
//  VoiceCheckInsertUserAuthStatusManager.h
//  AFNetworking
//
//  Created by wujie on 2018/5/31.
//

#import "HYDBaseRequestManager.h"

/**
声纹识别-保存用户声纹授权
http://118.26.170.236/pages/viewpage.action?pageId=13188124
 */
@interface VoiceCheckInsertUserAuthStatusManager : HYDBaseRequestManager

@property (nonatomic, assign) NSInteger status;

/**
 {
 "rspCode": 200,
 "rspMsg": "成功",
 "showMsg": "成功",
 "data": {
 "userId": "zsjwhluserid12345623456512341142",
 "status": 1
 }
 }
 1:保存成功 0:保存失败
 */
@end
