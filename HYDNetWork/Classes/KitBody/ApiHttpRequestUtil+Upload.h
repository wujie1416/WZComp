//
//  ApiHttpRequestUtil+Upload.h
//  AFNetworking
//
//  Created by cheyueyong on 2018/1/30.
//

#import <HYDNetWork/HYDNetWork.h>

typedef void(^ApiUploadSuccessCallBack) (id responses);
typedef void(^ApiUploadFailCallBack) (id response, NSError *err);

@interface ApiHttpRequestUtil (Upload)


/**
 批量上传图片文件，默认最多启动9个队列进行上传，上传的图片数量需和图片名称相同
 
 @param uploadUrl                 服务地址
 @param images                    上传的图片数组
 @param imageNames                上传图片的名字数组
 @param success                   成功的回调
 @param fail                      失败的回调
 
 @return 请求任务的queue
 */

- (NSOperationQueue *)uploadImagesWithOperation:(NSString *)uploadUrl
                                        images:(NSArray <UIImage *> *)images
                                    imageNames:(NSArray <NSString *> *)imageNames
                                       success:(ApiUploadSuccessCallBack)success
                                          fail:(ApiUploadFailCallBack)fail;



/**
 上传图片文件
 
 @param url                 服务地址
 @param fileData            上传的文件元数据
 @param name                上传文件的文件名称
 @param success             成功的回调
 @param fail                失败的回调
 @param flieUploadProgress  上传文件进度的回调
 
 @return 请求任务的taskIdentifier
 */
- (NSURLSessionDataTask *)uploadImageWithAFNRequestUrl:(NSString *)url
                                              fileData:(NSData *)fileData
                                                  name:(NSString *)name
                                               success:(ApiHTTPRequestCallBack)success
                                                  fail:(ApiHTTPRequestCallBack)fail
                                              progress:(ApiHTTPRequestUploadCallBack)flieUploadProgress;

/**
 上传文件
 
 @param url                 服务地址
 @param fileData            上传的文件元数据
 @param name                上传文件的文件名称
 @param mimeType            http://www.iana.org/assignments/media-types/.
 @param success             成功的回调
 @param fail                失败的回调
 @param flieUploadProgress  上传文件进度的回调
 
 @return 请求任务的taskIdentifier
 */
- (NSURLSessionDataTask *)uploadApiWithAFNRequestUrl:(NSString *)url
                                            fileData:(NSData *)fileData
                                                name:(NSString *)name
                                            mimeType:(NSString *)mimeType
                                             success:(ApiHTTPRequestCallBack)success
                                                fail:(ApiHTTPRequestCallBack)fail
                                            progress:(ApiHTTPRequestUploadCallBack)flieUploadProgress;

@end
