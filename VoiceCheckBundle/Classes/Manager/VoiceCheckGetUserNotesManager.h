//
//  VoiceCheckGetUserNotesManager.h
//  AFNetworking
//
//  Created by wujie on 2018/5/24.
//

#import "HYDBaseRequestManager.h"

/**
 获取用户须知
 http://118.26.170.236/pages/viewpage.action?pageId=13184867
 */
@interface VoiceCheckGetUserNotesManager : HYDBaseRequestManager
//出参
@property (nonatomic, copy) NSString *h5Url;

@end
/**
 {
 "rspCode":200,
 "rspMsg":"成功",
 "showMsg":"成功",
 "data":{
 "voiceIdentityH5Url":http://10.100.13.51/phb/app/phbsoundCustomer/agreement.html?__hbt=1526538197014
 }
 }
 */
