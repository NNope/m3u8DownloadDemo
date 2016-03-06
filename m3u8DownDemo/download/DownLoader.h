//
//  DownLoader.h
//  m3u8DownDemo
//
//  Created by 谈Xx on 16/3/5.
//  Copyright © 2016年 谈Xx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8List.h"
#import "SegmentDownLoader.h"

@interface DownLoader : NSObject<SegmentDownloadDelegate>

@property(nonatomic,retain) id <DownloadDelegate> delegate;
@property(nonatomic,retain) M3U8List *playlist;
// 当前写入大小
@property(nonatomic,assign) double writtenSize;
// 总大小
@property(nonatomic,assign) double totalSize;
// 当前总写入大小
@property (nonatomic, assign) double totalWrittenSize;
// 整体进度
@property(nonatomic,assign) double progress;
@property (nonatomic, strong) NSMutableArray *progressArray;
@property(nonatomic, assign) BOOL isDownloading;
/**
 *  分段下载器数组
 */
@property (nonatomic, strong) NSMutableArray *downloadArray;
/**
 *  每个视频的目录
 */
@property (nonatomic, copy) NSString *filePath;


-(instancetype)initWithM3U8List:(M3U8List *)list;

/**
 *  开始下载
 */
- (void)startDownload;

/**
 *  暂停下载
 */
- (void)suspendDownload;

-(NSString*)createLocalM3U8file;

@end
