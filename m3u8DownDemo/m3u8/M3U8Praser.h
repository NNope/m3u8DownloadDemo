//
//  M3U8Praser.h
//  m3u8DownDemo
//
//  Created by 谈Xx on 16/3/5.
//  Copyright © 2016年 谈Xx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M3U8List.h"
@class M3U8Praser;
//@class M3U8List;

@protocol M3U8PraseDelegate <NSObject>
@optional
// 解析完成
-(void)praseM3U8Finished:(M3U8Praser*)praser;
// 解析失败
-(void)praseM3U8Failed:(M3U8Praser*)praser;

@end


@interface M3U8Praser : NSObject

@property(nonatomic,retain)id<M3U8PraseDelegate> delegate;
// 列表 里面是info
@property(nonatomic,retain)M3U8List *segmentList;

/**
 *  解析M3u8文件url
 *
 *  @param urlstr M3u8的文件url
 */
-(void)praseM3u8Url:(NSString*)urlstr;

/**
 *  解析M3u8字符串
 *
 *  @param urlstr M3u8的文件url
 */
-(void)praseM3u8String:(NSString*)m3u8str;

@end
