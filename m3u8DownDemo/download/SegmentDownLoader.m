//
//  SegmentDownLoader.m
//  m3u8DownDemo
//
//  Created by 谈Xx on 16/3/5.
//  Copyright © 2016年 谈Xx. All rights reserved.
//

#import "SegmentDownLoader.h"

static  NSString * const kCurrentSession = @"kCurrentSession";


@implementation SegmentDownLoader

- (instancetype)initWithUrl:(NSString *)url andFilePathName:(NSString *)pathName andFileName:(NSString *)fileName
{
    self = [super init];
    if(self != nil)
    {
        self.downloadUrl = url;
        self.fileName = fileName;
        self.filePathName = pathName;
        
        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        // 拼接目录
        self.filePath = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.filePathName];
        // 创建目录
        BOOL isDir = NO;
        NSFileManager *fm = [NSFileManager defaultManager];
        if(!([fm fileExistsAtPath:self.filePath isDirectory:&isDir] && isDir))
        {
            // doc/download/movie1/
            [fm createDirectoryAtPath:self.filePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        self.status = DownloadTaskStatusStopped;
        
    }
    return  self;
}



// 开始 继续
- (void)start
{
    // 如果是之前被暂停的任务，就从已经保存的数据恢复下载
    if (self.partialData)
    {
        self.resumableTask = [self.currentSession downloadTaskWithResumeData:self.partialData];
    }
    else // 新建任务
    {
        // 废弃
//            self.downloadUrl = [self.downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.downloadUrl = [self.downloadUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.downloadUrl]];
        self.resumableTask = [self.currentSession downloadTaskWithRequest:request];
    }
    
    [self.resumableTask resume];
    self.status = DownloadTaskStatusRunning;
    
    
}

/**
 *  停止  不可恢复
 */
-(void)stop
{
    NSLog(@"segment download stop");
    if(self.resumableTask && self.status == DownloadTaskStatusRunning)
    {
        [self.resumableTask cancel];
    }
    self.status = DownloadTaskStatusStopped;
}

/**
 *  暂停下载
 */
-(void)suspend
{
    NSLog(@"segment download suspend");
    
    [self.resumableTask cancelByProducingResumeData:^(NSData *resumeData) {
        // 如果是可恢复的下载任务，应该先将数据保存到partialData中，注意在这里不要调用cancel方法
        self.partialData = resumeData;
        self.resumableTask = nil;
    }];
}

#pragma mark - NSURLSessionDownloadDelegate
/**
 *  下载成功才会调用
 *
 *  @param session
 *  @param downloadTask
 *  @param location       临时路径
 */
- (void)URLSession:(NSURLSession *)session
        downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    // 下载完成 系统下载在tmp中
    NSError *fileManagerError = nil;
    if (self.filePath)
    {
        self.filePath = [self.filePath stringByAppendingPathComponent:self.fileName];
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:self.filePath] error:&fileManagerError];
    }
    if (fileManagerError)
    {
        NSLog(@"fileManagerError:%@",fileManagerError);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentDownloadFinished:)])
    {
        [self.delegate segmentDownloadFinished:self];
    }
}

/* 完成下载任务，无论下载成功还是失败都调用该方法 */
// 暂停下载也会进来
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error)
    {
        if (error.code == NSURLErrorCancelled)
        {
            NSLog(@"下载取消");
            if (self.delegate && [self.delegate respondsToSelector:@selector(segmentDownload:Progresser:)])
            {
//                [self.delegate segmentDownloadCancelled:self Progresser:self.progresser];
            }
            return;
        }
        NSLog(@"下载失败:%@", error);
        if (self.delegate && [self.delegate respondsToSelector:@selector(segmentDownloadFailed:)])
        {
            [self.delegate segmentDownloadFailed:self];
        }
    }
    
//    [self stop];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten // 当前写入字节数
 totalBytesWritten:(int64_t)totalBytesWritten // 已写字节数
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite // 全部字节数
{
//    // 计算当前下载进度并更新视图
//    double downloadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;

    if (self.progresser.totalSize != (double)totalBytesExpectedToWrite)
    {
        self.progresser.totalSize = (double)totalBytesExpectedToWrite;
    }
    self.progresser.writtenSize = (double)bytesWritten;
    self.progresser.totalWritten = (double)totalBytesWritten;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentDownload:Progresser:)])
    {
        [self.delegate segmentDownload:self Progresser:self.progresser];
    }
    

}

// 恢复下载
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"恢复下载: Resume download at %f", (double)fileOffset);
}




- (NSURLSession *)currentSession
{
    if (_currentSession == nil)
    {
        NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.currentSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:self delegateQueue:nil];
        self.currentSession.sessionDescription = kCurrentSession;
    }
    return _currentSession;
}

-(SegmentProgresser *)progresser
{
    if (_progresser == nil)
    {
        _progresser = [[SegmentProgresser alloc] init];
    }
    return _progresser;
}

@end
