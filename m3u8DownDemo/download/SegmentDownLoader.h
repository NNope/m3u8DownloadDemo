//
//  SegmentDownLoader.h
//  m3u8DownDemo
//
//  Created by 谈Xx on 16/3/5.
//  Copyright © 2016年 谈Xx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadDelegate.h"
#import "SegmentProgresser.h"

#define kPathDownload @"Download"

typedef enum
{
    DownloadTaskStatusRunning = 0,
    DownloadTaskStatusStopped = 1,
}DownloadTaskStatus;

@interface SegmentDownLoader : NSObject<NSURLSessionDownloadDelegate>

@property(nonatomic,copy) NSString *fileName;
@property(nonatomic,copy) NSString *filePathName;
@property(nonatomic,copy) NSString *filePath;
@property(nonatomic,copy) NSString *downloadUrl;
@property(nonatomic,retain) id <SegmentDownloadDelegate>delegate;
@property(nonatomic,assign)DownloadTaskStatus status;
// 当前会话
@property (strong, nonatomic) NSURLSession *currentSession;
// 下载任务
@property (nonatomic, strong) NSURLSessionDownloadTask *resumableTask;
// 用于可恢复的下载任务的数据
@property (strong, nonatomic) NSData *partialData;
@property (nonatomic, strong) SegmentProgresser *progresser;

@property(nonatomic,copy)NSString *tmpFileName;

- (instancetype)initWithUrl:(NSString*)url andFilePathName:(NSString*)pathName  andFileName:(NSString*)fileName;

/**
 *  开始、继续
 */
- (void)start;
- (void)suspend;
- (void)stop;
@end
