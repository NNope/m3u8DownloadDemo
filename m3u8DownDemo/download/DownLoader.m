//
//  DownLoader.m
//  m3u8DownDemo
//
//  Created by 谈Xx on 16/3/5.
//  Copyright © 2016年 谈Xx. All rights reserved.
//

#import "DownLoader.h"

@implementation DownLoader

-(instancetype)initWithM3U8List:(M3U8List *)list
{
    if (self = [super init])
    {
        self.playlist = list;
        self.progress = 0.0;
        self.writtenSize = 0.0;
        self.totalSize = 0.0;
        self.filePath = self.playlist.filePath;
    }
    return  self;
}

/**
 *  开始下载
 */
-(void)startDownload
{
    if(self.downloadArray == nil)
    {
        self.downloadArray = [[NSMutableArray alloc]init];
        for(int i = 0;i< self.playlist.length;i++)
        {
            // 一个文件名
            NSString *fileName = [NSString stringWithFormat:@"%d.ts",i];
            // 根据索引获得片段info
            M3U8SegmentInfo *segment = [self.playlist getSegment:i];
            // 创建分段下载器
            SegmentDownLoader *sgDownloader = [[SegmentDownLoader alloc] initWithUrl:segment.locationUrl andFilePathName:self.playlist.filePath andFileName:fileName];
            sgDownloader.delegate = self;
            [self.downloadArray addObject:sgDownloader];
        }
    }
    for(SegmentDownLoader *obj in self.downloadArray)
    {
        [obj start];
    }
    self.isDownloading = YES;
}
/**
 *  暂停下载
 */
- (void)suspendDownload
{
    NSLog(@"suspendDownload");
    if(self.isDownloading && self.downloadArray != nil)
    {
        for(SegmentDownLoader *obj in self.downloadArray)
        {
            [obj suspend];
        }
        self.isDownloading = NO;
    }
}

-(NSString*)createLocalM3U8file
{
    if(self.playlist !=nil)
    {
        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:self.filePath];
        NSString *fullpath = [saveTo stringByAppendingPathComponent:@"movie.m3u8"];
        
        NSLog(@"createLocalM3U8file:%@",fullpath);
        
        //创建文件头部
        NSString* head = @"#EXTM3U\n#EXT-X-TARGETDURATION:30\n#EXT-X-VERSION:2\n#EXT-X-DISCONTINUITY\n";
        
        NSString* segmentPrefix = [NSString stringWithFormat:@"http://127.0.0.1:12345/%@/",self.filePath];
        //填充片段数据
        for(int i = 0;i< self.playlist.length;i++)
        {
            NSString* filename = [NSString stringWithFormat:@"id%d.ts",i];
            M3U8SegmentInfo* segInfo = [self.playlist getSegment:i];
            NSString* length = [NSString stringWithFormat:@"#EXTINF:%ld,\n",(long)segInfo.duration];
            NSString* url = [segmentPrefix stringByAppendingString:filename];
            head = [NSString stringWithFormat:@"%@%@%@\n",head,length,url];
        }
        //创建尾部
        NSString* end = @"#EXT-X-ENDLIST";
        head = [head stringByAppendingString:end];
        NSMutableData *writer = [[NSMutableData alloc] init];
        [writer appendData:[head dataUsingEncoding:NSUTF8StringEncoding]];
        
        BOOL bSucc =[writer writeToFile:fullpath atomically:YES];
        if(bSucc)
        {
            NSLog(@"create m3u8file succeed; fullpath:%@, content:%@",fullpath,head);
            return  fullpath;
        }
        else
        {
            NSLog(@"create m3u8file failed");
            return  nil;
        }
    }
    return nil;
}


#pragma mark - SegmentDownloadDelegate

// 每个下载器下载完成
-(void)segmentDownloadFinished:(SegmentDownLoader *)request
{
    NSLog(@"a segment Download Finished");
    [self.downloadArray removeObject:request];
    if([self.downloadArray count] == 0)
    {
        self.progress = 1;
        self.downloadArray = nil;
        NSLog(@"-----100%%-------all the segments downloaded. video download finished");
        if(self.delegate && [self.delegate respondsToSelector:@selector(downloaderFinished:)])
        {
            [self.delegate downloaderFinished:self];
        }
        // 总下载字节数有时候有误差
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:Progress:)])
        {
            [self.delegate downloader:self Progress:self.progress];
        }
        self.progress = 0;
        self.writtenSize = 0.0;
        self.isDownloading = NO;
    }
}

// 进度
- (void)segmentDownload:(SegmentDownLoader *)request Progresser:(SegmentProgresser *)progresser
{
    self.writtenSize += progresser.writtenSize;
    
    // 获取全部数组 为了得到里面的total
    if (![self.progressArray containsObject:progresser])
    {
        [self.progressArray addObject:progresser];
    }
    // 如果全加进来， 开始获取总大小
    if (self.progressArray.count == self.playlist.segments.count)
    {
        // 计算总大小
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            for (SegmentProgresser *obj in self.progressArray)
            {
                self.totalSize += obj.totalSize;
            }
            NSLog(@"文件总大小 ---- %.4f",self.totalSize);
        });

        self.progress = self.writtenSize/self.totalSize;

        if (self.progress < 1.0) // 已完成
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(downloader:Progress:)])
            {
                [self.delegate downloader:self Progress:self.progress];
            }
        }

    }
    
    
}

// 暂停下载
- (void)segmentDownloadCancelled:(SegmentDownLoader *)request Progresser:(SegmentProgresser *)progresser
{
    NSLog(@"原本写入大小 %.4f",self.writtenSize);
    self.totalWrittenSize +=  progresser.totalWritten;
    self.writtenSize = self.totalWrittenSize;
    NSLog(@"暂停下载 已下载 %.4f 修改后写入大小 %.4f",progresser.totalWritten,self.writtenSize);
}

// 下载失败
-(void)segmentDownloadFailed:(SegmentDownLoader *)request
{
    NSLog(@"segmentDownloadFailed");
//    [self.downloadArray removeObject:request];
}

-(NSMutableArray *)progressArray
{
    if (_progressArray == nil)
    {
        _progressArray = [NSMutableArray array];
    }
    return _progressArray;
}
@end
