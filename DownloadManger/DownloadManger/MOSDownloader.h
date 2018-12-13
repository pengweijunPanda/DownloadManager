//
//  MOSDownloader.h
//  MosChat
//
//  Created by pengweijun on 2018/12/4.
//  Copyright © 2018年 YY.INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MOSDownloader : NSObject

+ (instancetype)shareInstance;

/**
 下载资源

 @param url 下载资源链接
 @param callback 成功或失败回调
 */
- (void)downloadUrl:(NSString *)url complete:(void (^)(BOOL ,NSString *))callback;

/**
 下载资源

 @param url 下载资源链接
 @param progressCallback 下载进度
 @param callback 成功或失败回调
 */
- (void)downloadUrl:(NSString *)url progress:(nullable void (^)(CGFloat percentage))progressCallback complete:(void (^)(BOOL ,NSString *))callback;


- (void)saveKey:(NSString *)key value:(NSString *)value;

- (NSString *)getValueForKey:(NSString *)key;

- (void)saveFileToPathPrefix:(NSString *)pathPrefix subFilePath:(NSString *)subFilePath;

- (NSMutableDictionary *)fileType:(NSString *)fileType fromPath:(NSString *)fromPath;

@end

NS_ASSUME_NONNULL_END
