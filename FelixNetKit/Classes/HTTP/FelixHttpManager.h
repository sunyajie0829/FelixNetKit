//
//  FelixHttpManager.h
//  FelixNetKit
//
//  Created by weistek on 2019/2/20.
//  Copyright © 2019 weistek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
@interface FelixHttpManager : NSObject

/**
 全局设置请求的类型,默认为x-www-form-urlencode,设置为YES则以raw也就是JSON的请求体进行请求
 */
@property (nonatomic,assign) BOOL requestTypeIsJSON;

/**
 全局设置请求超时的时间
 */
@property (nonatomic,assign) NSTimeInterval requestTimeOut;

/**
 FelixHttpManager单例对象

 @return 返回一个FelixHttpManager单例对象
 */
+ (instancetype)sharedManager;
/**
 GET方式请求数据

 @param urlStr 目标地址
 @param parameter 请求参数
 @param success 请求成功的回调
 @param failure 请求失败的回调
 */
- (void)GETWithUrlStr:(NSString *)urlStr parameter:(NSDictionary *)parameter success:(void(^)(NSURLSessionDataTask * task, id  responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 POST方式请求数据

 @param urlStr 目标地址
 @param parameter 请求参数
 @param success 请求成功的回调
 @param failure 请求失败的回调
 */
- (void)POSTWithUrlStr:(NSString *)urlStr parameter:(NSDictionary *)parameter success:(void(^)(NSURLSessionDataTask * task, id  responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 上传本地文件到服务器

 @param urlStr 目标地址
 @param fileUrls 文件的url地址
 @param progress 上传进度
 @param success 上传成功的回调
 @param failure 上传失败的回调
 */
- (void)uploadFileWithUrl:(NSString *)urlStr fileUrls:(NSArray<NSURL *> *)fileUrls progress:(void(^)(NSProgress *uploadProgress))progress success:(void(^)(NSURLSessionDataTask * task, id  responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 从服务端下载文件

 @param url 下载地址
 @param progress 下载进度
 @param savePath 文件保存地址
 @param complete 下载完成的回调
 */
- (void)downLoadFileWithUrlStr:(NSString *)url progress:(void(^)(NSProgress *uploadProgress))progress savePath:(NSString *)savePath complete:(void(^)(NSURLResponse * resp, NSString * path, NSError * err))complete;
@end
