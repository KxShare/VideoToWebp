//  ViewController.m
//  VideoToWebpDemo
//
//  Created by K·X on 2018/5/3.
//  Copyright © 2018年 kanxiang. All rights reserved.
//

#import "ViewController.h"
#import <YYImage.h>
#import <YYWebImage.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
- (IBAction)btnSaveClicked:(id)sender;
@property (weak, nonatomic) IBOutlet YYAnimatedImageView *centerAnimateView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)createFilePath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager new];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        
    } else {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSString *)createWebpFilePath{
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/Media"];
    [self createFilePath:path];
    NSString *uuidStr = [[NSUUID UUID] UUIDString];
    NSString * fileName = [NSString stringWithFormat:@"S_%@.webp",uuidStr];
    return [path stringByAppendingPathComponent:fileName];
}

- (NSString * )saveToWebpByVideoPath:(NSURL *)videoUrl{
    NSString * filePath = [self createWebpFilePath];
    YYImageEncoder *gifEncoder = [[YYImageEncoder alloc] initWithType:YYImageTypeWebP];
    gifEncoder.loopCount = 0;
    gifEncoder.quality = 0.8;
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    int64_t value = asset.duration.value;
    int64_t scale = asset.duration.timescale;
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    //下面两个值设为0表示精确取帧，否则系统会有优化取出来的帧时间间隔不对等
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    
    for (int i = 0; i <=4; i++) {
        CGFloat starttime = i*0.1+0.5;
        CMTime time = CMTimeMakeWithSeconds(starttime, (int)scale);
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage * img = [UIImage imageWithCGImage:image];
        img = [self resizeToMaxHeight:480 img:img];
        [gifEncoder addImage:img duration:0.1];
        CGImageRelease(image);
    }
    for (int i=3; i>=0; i--) {
        CGFloat starttime = i*0.1+0.5;
        CMTime time = CMTimeMakeWithSeconds(starttime, (int)scale);
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage * img = [UIImage imageWithCGImage:image];
        img = [self resizeToMaxHeight:480 img:img];
        [gifEncoder addImage:img duration:0.1];
        CGImageRelease(image);
    }
    
    [gifEncoder encodeToFile:filePath];
    NSLog(@"生成webp成功!");
    return filePath;
}

- (UIImage *)resizeToMaxHeight:(CGFloat)height img:(UIImage *)img{
    if (img.size.width<img.size.height) {
        if (img.size.height>height) {
            CGSize newSize = CGSizeMake(height*1.0*img.size.width/img.size.height, height);
            img = [img yy_imageByResizeToSize:newSize contentMode:UIViewContentModeScaleToFill];
        }
    }
    else{
        if (img.size.width>height) {
            CGSize newSize = CGSizeMake(height,img.size.height*height*1.0/img.size.width);
            img = [img yy_imageByResizeToSize:newSize contentMode:UIViewContentModeScaleToFill];
        }
    }
    return img;
}


- (IBAction)btnSaveClicked:(id)sender {
    NSString * videoPath = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"mp4"];
    NSURL * videoUrl = [NSURL fileURLWithPath:videoPath];
    NSString * webpFilePath = [self saveToWebpByVideoPath:videoUrl];
    YYImage * tmpImg = [YYImage imageWithContentsOfFile:webpFilePath];
    self.centerAnimateView.image = tmpImg;
}
@end
