//
//  MOSDownloader.m
//  MosChat
//
//  Created by pengweijun on 2018/12/4.
//  Copyright © 2018年 YY.INC. All rights reserved.
//

#import "MOSDownloader.h"
#import <AFNetworking/AFNetworking.h>

@implementation MOSDownloader

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static MOSDownloader *downloader = nil;
    dispatch_once(&onceToken, ^{
        downloader = [[MOSDownloader alloc]init];
    });
    return downloader;
}

- (void)downloadUrl:(NSString *)url complete:(void (^)(BOOL isSuccess,NSString *filePath))callback{
    [self downloadUrl:url progress:nil complete:callback];
}


- (void)downloadUrl:(NSString *)url progress:(nullable void (^)(CGFloat))progressCallback complete:(nonnull void (^)(BOOL, NSString * _Nonnull))callback{
    AFHTTPSessionManager *session= [AFHTTPSessionManager manager];//[YYWebResourceDownloader sharedDownloader].afn_manager;
    
    session.requestSerializer = [AFHTTPRequestSerializer serializer];
    [session.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
 
    session.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];//超时20秒时间
    
    
    NSURLSessionDownloadTask * task = [session downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (progressCallback) {
                progressCallback(downloadProgress.fractionCompleted);
            }
            NSLog(@"下载完成了: %.2f ",downloadProgress.fractionCompleted);
        }];
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [targetPath URLByAppendingPathExtension:@"zip"];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (callback) {
            callback(error?NO:YES,filePath.relativePath);
        }
        NSLog(@"下载完成了 %@  \n错误：%@",filePath,error.description);
        if (!error) {
            
        }
        else{
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath.relativePath]) {
                NSLog(@"下载失败删除源文件！");
                [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
            }
        };
    }];
    [task resume];
}

- (void)saveKey:(NSString *)key value:(NSString *)value{
    
    [[NSUserDefaults standardUserDefaults]setObject:value forKey:key];
    
    [[NSUserDefaults standardUserDefaults]synchronize];

}

- (NSString *)getValueForKey:(NSString *)key{
    
    NSString *result = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    
    return result;
}


- (void)saveFileToPathPrefix:(NSString *)pathPrefix subFilePath:(NSString *)subFilePath{
    
}

- (NSMutableDictionary *)fileType:(NSString *)fileType fromPath:(NSString *)fromPath{
    
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:fromPath];
    
    NSString *fileName;
    
    NSMutableDictionary *R = [NSMutableDictionary dictionary];
    
    while (fileName = [dirEnum nextObject]) {
        NSString *value = [fromPath stringByAppendingPathComponent:fileName];

        NSLog(@"短路径:%@", fileName);
        NSLog(@"全路径:%@", value);
        if ([fileName hasSuffix:fileType]) {
            NSString *key = [fileName componentsSeparatedByString:@"/"].lastObject;
            [R setObject:value forKey:key];
        }
    }
    
    return R;
}


@end
