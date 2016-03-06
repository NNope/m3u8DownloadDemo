//
//  M3U8SegmentInfo.h
//  m3u8DownDemo
//
//  Created by 谈Xx on 16/3/5.
//  Copyright © 2016年 谈Xx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3U8SegmentInfo : NSObject
/**
 *  片段长度
 */
@property(nonatomic,assign)NSInteger duration;
/**
 *  片段url
 */
@property(nonatomic,copy)NSString *locationUrl;

@end
