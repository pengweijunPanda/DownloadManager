//
//  ViewController.m
//  DownloadManger
//
//  Created by pengweijun on 2018/12/13.
//  Copyright © 2018年 彭伟军. All rights reserved.
//

#import "ViewController.h"

#import "MOSDownloader.h"

#import <SSZipArchive/SSZipArchive.h>


@interface ViewController ()
@property (nonatomic,copy)NSString *theKey;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.theKey = @"kingOfX";
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)downloadClick:(UIButton *)sender {
    
    NSLog(@"点了下载按钮");
    
    NSString *downloadZipUrl = @"https://static.moschat.com/plugin-plf/tools.zip";
    
    //    @weakify(self);
    //    [self processListDownloadUrl:downloadUrl body:bodyDic callback:^{
    //        @strongify(self);
    
    
    if ([[MOSDownloader shareInstance] getValueForKey:self.theKey]) {
        NSLog(@"本地已存在插件");
        
        NSString *key = [[MOSDownloader shareInstance] getValueForKey:self.theKey];
        //        NSString *path = [[MOSDownloader shareInstance] getValueForKey:key];
        
        //        NSLog(@"本地已存在插件:%@",path);
        
        NSString * toPath = [self filePathSuffix:@"pluginPackages_result"];
        NSArray *pngs = [[NSFileManager defaultManager] subpathsAtPath:toPath];
        
        
        if (pngs.count > 1) {
            //真的存在
            // 拼接tools/
        }else{
            //提示error
            //移除此路径资源
            //去下载
        }
        
        
        //本地存在插件包了
        //1.对比fwq-插件包地址
        
        //  相同就不做处理
        
        //  不同就继续下载最新版插件
        
        
    }else{
        NSLog(@"本地没有插件包");
        
        //本地没有插件包
        
        //1.检查目标folder是否有zip
        
        //  有->解压缩->loadLua
        
        //  无->去下载
        
        [self download:downloadZipUrl];
        
    }
    
}

- (NSString *)filePathSuffix:(NSString *)suffix{
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString * path = [[paths objectAtIndex:0] stringByAppendingPathComponent:suffix] ;
    
    return path;
}


- (NSArray *)copyFileType:(NSString *)fileType toSubFolder:(NSString *)subFolderName{
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSString * path = [self filePathSuffix:@"pluginPackages_download"];
    
    NSString * toPath = [self filePathSuffix:@"pluginPackages_result"];
    
    toPath = [toPath stringByAppendingPathComponent:subFolderName];
    
    if(![fm fileExistsAtPath:toPath]){  //如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        NSLog(@"first run");
        [fm createDirectoryAtPath:toPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSArray *files = [fm subpathsAtPath:path];
    
    NSDictionary *pngDic = [[MOSDownloader shareInstance] fileType:fileType fromPath:path];
    
    [pngDic.allKeys enumerateObjectsUsingBlock:^(NSString *  _Nonnull pngKey, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *pngPath = pngDic[pngKey];
        NSString *tempToPath = [toPath stringByAppendingPathComponent:pngKey];
        //[fm moveItemAtPath:pngPath toPath:tempToPath error:nil];
        [fm copyItemAtPath:pngPath toPath:tempToPath error:nil];
    }];
    
    return files;
    
}

- (void)download:(NSString *)url{
    
    [[MOSDownloader shareInstance] downloadUrl:url complete:^(BOOL isSuccess, NSString * _Nonnull filePath) {
        if (isSuccess) {
            
            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            NSString * path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"pluginPackages_download"] ;
            //解压
            NSString *tempZipDir = [path stringByAppendingPathComponent:@"myZip"];
            
            NSLog(@"---> :%@",tempZipDir);
            
            [[MOSDownloader shareInstance] saveKey:self.theKey value:url];
            
            [[MOSDownloader shareInstance] saveKey:url value:tempZipDir];
            
            [self unzipFilePath:filePath toDestination:tempZipDir fileName:url.lastPathComponent callBack:^(BOOL isSucc) {
                if (isSucc) {
                    NSLog(@"解压缩成功");
                    
                    NSArray *pngs = [self copyFileType:@".png" toSubFolder:@"image"];
                    NSArray *luas = [self copyFileType:@".lua" toSubFolder:@"lua"];
                    NSArray *fonts = [self copyFileType:@".otf" toSubFolder:@"font"];
                    
                }else{
                    NSLog(@"解压缩失败");
                    
                }
            }];
        }else{
            NSLog(@"下载失败");
        }
        
    }];
}



- (void)unzipFilePath:(NSString *)filePath toDestination:(NSString *)toDestination fileName:(NSString *)fileName callBack:(void (^)(BOOL))block{
    
    [SSZipArchive unzipFileAtPath:filePath
                    toDestination:toDestination
                  progressHandler:nil
                completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
                    if (block) {
                        block(error?NO:YES);
                    }
                }];
    
}

@end
