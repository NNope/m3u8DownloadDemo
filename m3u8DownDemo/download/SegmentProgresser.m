//
//  SegmentProgresser.m
//  m3u8DownloadDemo
//
//  Created by 谈Xx on 16/3/5.
//  Copyright © 2016年 谈Xx. All rights reserved.
//

#import "SegmentProgresser.h"

@implementation SegmentProgresser

-(instancetype)init
{
    if (self = [super init])
    {
        self.totalSize = 0.0;
        self.totalWritten = 0.0;
        self.writtenSize = 0.0;
    }
    return self;
}

@end
