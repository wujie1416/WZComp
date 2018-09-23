//
//  VoiceCheckgetUploadUrlManager.h
//  AFNetworking
//
//  Created by wujie on 2018/5/31.
//

#import "HYDBaseRequestManager.h"
/**
 获取上传文件地址，用以上传文件
 http://118.26.170.236/pages/viewpage.action?pageId=13187672
 */
@interface VoiceCheckgetUploadUrlManager : HYDBaseRequestManager
//入参
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *apiVersion;

//出参
/**
 url         用于上传文件的url
 uid         需要通过具体业务接口中回传给服务端
 itemId         需要通过具体业务接口中回传给服务端
 */
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *url;
/**
 
 category    "voice"
 apiVersion  "ver2"
 
 
 
 {
 "rspCode": 200,
 "rspMsg": "成功",
 "showMsg": "成功",
 "data": {
 "uid": "100",
 "itemId": "269101",
 "url": "http://10.100.19.101:30401/fileSystem/uploadfiles?token=MjVCWlhtdmFNNjdiZzJRMk4xeE1ScHk0SE14T1QwUDNWMHlBNXhFYmU2Y3FXbzkwb2txdGM5amkyd2gtYg%3D%3D"
 },
 "code": 200,
 "msg": "成功"
 }
 */
@end
