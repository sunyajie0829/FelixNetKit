//
//  FelixHttpManager.m
//  FelixNetKit
//
//  Created by weistek on 2019/2/20.
//  Copyright © 2019 weistek. All rights reserved.
//

#import "FelixHttpManager.h"

@implementation FelixHttpManager
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static FelixHttpManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[FelixHttpManager alloc] init];
        manager.requestTypeIsJSON = NO;
        manager.requestTimeOut = -1;
    });
    return manager;
}
- (void)GETWithUrlStr:(NSString *)urlStr parameter:(NSDictionary *)parameter success:(void(^)(NSURLSessionDataTask * task, id  responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure{
    __block AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = self.requestTimeOut > 0 ? self.requestTimeOut : 30;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",nil];
    [manager GET:urlStr parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(task,responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task,error);
        [manager invalidateSessionCancelingTasks:YES];
    }];
}
- (void)POSTWithUrlStr:(NSString *)urlStr parameter:(NSDictionary *)parameter success:(void(^)(NSURLSessionDataTask * task, id  responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure{
    __block AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    self.requestTypeIsJSON ? manager.requestSerializer = [AFJSONRequestSerializer serializer] : [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = self.requestTimeOut > 0 ? self.requestTimeOut : 30;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",nil];
    [manager POST:urlStr parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(task,responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task,error);
        [manager invalidateSessionCancelingTasks:YES];
    }];
}
- (void)uploadFileWithUrl:(NSString *)urlStr fileUrls:(NSArray<NSURL *> *)fileUrls progress:(void(^)(NSProgress *uploadProgress))progress success:(void(^)(NSURLSessionDataTask * task, id  responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure{
    __block AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",nil];
    [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSURL *fileUrl in fileUrls) {
            NSError *uploadError = nil;
            [formData appendPartWithFileURL:fileUrl name:@"file" error:&uploadError];
            fileUrl ? NSLog(@"upload file error:%@",uploadError) : nil;
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(task,responseObject);
        [manager invalidateSessionCancelingTasks:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task,error);
        [manager invalidateSessionCancelingTasks:YES];
    }];
}
- (void)downLoadFileWithUrlStr:(NSString *)url progress:(void(^)(NSProgress *uploadProgress))progress savePath:(NSString *)savePath complete:(void(^)(NSURLResponse * resp, NSString * path, NSError * err))complete
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:savePath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    __block AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    [[manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress){
            progress(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //保存的文件路径
        NSString *fullPath = [savePath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (complete){
            complete(response,[[filePath absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""],error);
        }
        [manager invalidateSessionCancelingTasks:YES];
    }] resume];
}
@end
