//
//  DownloadDelegate.h
//  m3u8DownDemo
//
//  Created by 谈Xx on 16/3/5.
//  Copyright © 2016年 谈Xx. All rights reserved.
//
#import <Foundation/Foundation.h>

@class SegmentDownLoader;
@class SegmentProgresser;
@protocol SegmentDownloadDelegate <NSObject>
@optional
-(void)segmentDownloadFinished:(SegmentDownLoader *)request;
-(void)segmentDownloadFailed:(SegmentDownLoader *)request;
-(void)segmentDownloadCancelled:(SegmentDownLoader *)request
                     Progresser:(SegmentProgresser *)progresser;
// 进度
- (void)segmentDownload:(SegmentDownLoader *)request
             Progresser:(SegmentProgresser *)progresser;

@end


@class DownLoader;
@protocol DownloadDelegate <NSObject>
@optional
-(void)downloaderFinished:(DownLoader *)download;
-(void)downloaderFailed:(DownLoader *)download;
-(void)downloader:(DownLoader *)download Progress:(double)progess;
@end