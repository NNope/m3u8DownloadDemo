//
//  SegmentProgresser.h
//  m3u8DownloadDemo
//
//  Created by 谈Xx on 16/3/5.
//  Copyright © 2016年 谈Xx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SegmentProgresser : NSObject

@property (nonatomic, assign) double totalSize;
@property (nonatomic, assign) double writtenSize;
// 当前已写字节数 暂停使用
@property (nonatomic, assign) double totalWritten;


@end
