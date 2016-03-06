//
//  M3U8List.h
//  m3u8DownDemo
//
//  Created by 谈Xx on 16/3/5.
//  Copyright © 2016年 谈Xx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8SegmentInfo.h"

@interface M3U8List : NSObject

/**
 *  片段数组
 */
@property (nonatomic, retain) NSMutableArray *segments;
/**
 *  片段个数
 */
@property (assign) NSInteger length;
/**
 *  父目录-视频目录
 */
@property (nonatomic,copy)NSString* filePath;

- (instancetype)initWithSegments:(NSMutableArray *)segmentList;

/**
 *  得到对应索引的片段内容
 *
 *  @param index
 *
 *  @return
 */
- (M3U8SegmentInfo *)getSegment:(NSInteger)index;

@end
