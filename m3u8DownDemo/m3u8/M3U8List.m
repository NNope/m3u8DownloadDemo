//
//  M3U8List.m
//  m3u8DownDemo
//
//  Created by 谈Xx on 16/3/5.
//  Copyright © 2016年 谈Xx. All rights reserved.
//

#import "M3U8List.h"

@implementation M3U8List

- (instancetype)initWithSegments:(NSMutableArray *)segmentList
{
    if (self = [super init])
    {
        self.segments = segmentList;
        self.length = segmentList.count;
    }
    return self;
}


/**
 *  得到对应索引的片段内容
 *
 *  @param index
 *
 *  @return
 */
- (M3U8SegmentInfo *)getSegment:(NSInteger)index
{
    if( index >=0 && index < self.length)
    {
        return (M3U8SegmentInfo *)[self.segments objectAtIndex:index];
    }
    else
    {
        return nil;
    }
}

@end
