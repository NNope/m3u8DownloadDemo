//
//  ViewController.m
//  m3u8DownDemo
//
//  Created by 谈Xx on 16/3/5.
//  Copyright © 2016年 谈Xx. All rights reserved.
//

#import "ViewController.h"
#import "M3U8Praser.h"
#import "DownLoader.h"

@interface ViewController ()<M3U8PraseDelegate,DownloadDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnDown;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;
@property (weak, nonatomic) IBOutlet UILabel *lblProgress;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)downloadClick:(UIButton *)sender;
- (IBAction)stopClick:(UIButton *)sender;
- (IBAction)btnPlaycClick:(id)sender;

@property (nonatomic, strong) M3U8Praser *m3u8Praser;
@property (nonatomic, strong) DownLoader *downloader;
@property (nonatomic, copy) NSString *localM3u8Str;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSLog(@"沙盒---path----%@",path);
    // 读取本地文件
//    path = [path stringByAppendingPathComponent:@"11.m3u8"];
//    NSString *m3u8Str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    // 直接url
    NSString *m3u8Str = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://pl.youku.com/playlist/m3u8?vid=118402875&type=mp4&ts=1457242986&keyframe=0&ep=dSaRHUuJVMcI4CrZgT8bYH2xc3cIXP8L%2FhuFg9plBdQnS%2By2&sid=7457242985969127ac707&token=3349&ctype=12&ev=1&oip=2105010896"] encoding:NSUTF8StringEncoding error:nil];
    
    self.m3u8Praser = [[M3U8Praser alloc] init];
    self.m3u8Praser.delegate = self;
    [self.m3u8Praser praseM3u8String:m3u8Str];
}


#pragma mark - M3U8PraseDelegate
// 解析完成
-(void)praseM3U8Finished:(M3U8Praser*)praser
{
    NSLog(@"=====praseM3U8Finished=======");
    
    // 视频文件父目录
    praser.segmentList.filePath = @"moive1";
    // 一个下载器
    self.downloader = [[DownLoader alloc]initWithM3U8List:praser.segmentList];
    self.downloader.delegate = self;
}
// 解析失败
-(void)praseM3U8Failed:(M3U8Praser*)praser
{
    NSLog(@"=====praseM3U8Failed=======");
}

#pragma mark - DownloadDelegate
-(void)downloader:(DownLoader *)request Progress:(double)progess
{
    NSString *str = [NSString stringWithFormat:@"%0.1f%%",progess*100];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.lblProgress.text = str;
    });
}

-(void)downloaderFinished:(DownLoader *)download
{
    self.localM3u8Str = [download createLocalM3U8file];
}



- (IBAction)downloadClick:(UIButton *)sender
{
    if (self.downloader)
    {
        [self.downloader startDownload];
    }
}

// 暂停
- (IBAction)stopClick:(UIButton *)sender
{
    if (self.downloader) {
        [self.downloader suspendDownload];
    }
}

- (IBAction)btnPlaycClick:(id)sender
{
    
    [ self.webView loadRequest:[[NSURLRequest alloc]initWithURL:[[NSURL alloc]initWithString:@"http://127.0.0.1:12345/moive1/movie.m3u8"]]];
}
@end
