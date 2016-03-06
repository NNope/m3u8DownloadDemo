//
//  M3U8Praser.m
//  m3u8DownDemo
//
//  Created by 谈Xx on 16/3/5.
//  Copyright © 2016年 谈Xx. All rights reserved.
//

#import "M3U8Praser.h"
#import "M3U8SegmentInfo.h"
#import "M3U8List.h"

@implementation M3U8Praser


//解析m3u8的内容
- (void)praseM3u8Url:(NSString *)urlstr
{
    
    NSLog(@"---begin------");
    
    // 根本就不包含
    if([urlstr containsString:@"m3u8"] == FALSE)
    {
        NSLog(@" Invalid url");
        // 告诉代码失败
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Failed:)])
        {
            [self.delegate praseM3U8Failed:self];
        }
        return;
    }
    
    // 转成url
    NSURL *url = [[NSURL alloc] initWithString:urlstr];
    NSError *error = nil;
    NSStringEncoding encoding;
    // 把对应的M3u8url 文件 获取为string
    NSString *m3u8Str = [[NSString alloc] initWithContentsOfURL:url
                                                usedEncoding:&encoding
                                                       error:&error];
    [self praseM3u8String:m3u8Str];
    
}

- (void)praseM3u8String:(NSString *)m3u8str
{
    if(m3u8str == nil)
    {
        NSLog(@"data is nil");
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Failed:)])
        {
            [self.delegate praseM3U8Failed:self];
        }
        return;
    }
    
    NSMutableArray *segments = [[NSMutableArray alloc] init];
    NSString* remainData =m3u8str;
    // 找到第一个片段的位置
    NSRange segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    while (segmentRange.location != NSNotFound)
    {
        // 每一个片段
        M3U8SegmentInfo * segment = [[M3U8SegmentInfo alloc]init];
        
        // 获取片段长度↓↓↓↓↓↓↓↓↓↓↓↓
        /**
         *  #EXTM3U
         #EXT-X-TARGETDURATION:12
         #EXT-X-VERSION:2
         #EXTINF:6,
         */
        NSRange commaRange = [remainData rangeOfString:@","];
        // location #EXTINF:  len ,减去: 得到长度数字
        NSString* value = [remainData substringWithRange:NSMakeRange(segmentRange.location + [@"#EXTINF:" length], commaRange.location -(segmentRange.location + [@"#EXTINF:" length]))];
        segment.duration = [value intValue];
        
        
        // 获取片段url↓↓↓↓↓↓↓↓↓↓↓↓
        /* 剩下的
         ,
         http://202.102.93.173/69760FB8D783A8182AE62365CA/0300080100509EE191556504E9D2A7B927B331-4838-3F56-5086-635F9DC3D5C8.mp4.ts?ts_start=0&ts_end=5.9&ts_seg_no=0&ts_keyframe=1
         #EXTINF:3,.........
         */
        remainData = [remainData substringFromIndex:commaRange.location];
        NSRange linkRangeBegin = [remainData rangeOfString:@"http"];
        NSRange linkRangeEnd = [remainData rangeOfString:@"#"];
        // 下载url
        NSString* linkurl = [remainData substringWithRange:NSMakeRange(linkRangeBegin.location, linkRangeEnd.location - linkRangeBegin.location)];
        segment.locationUrl = linkurl;
        
        [segments addObject:segment];
        // 构成while循环
        remainData = [remainData substringFromIndex:linkRangeEnd.location];
        segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    }
    // 解析完成 一个数组 一个数组长度
    M3U8List * thePlaylist = [[M3U8List alloc] initWithSegments:segments];
    self.segmentList = thePlaylist;
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Finished:)])
    {
        [self.delegate praseM3U8Finished:self];
    }

}


@end
