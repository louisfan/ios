//
//  FLWAsynchronous.m
//  FLWNetWork
//
//  Created by LW on 14-3-11.
//  Copyright (c) 2014年 Liuwei.fan. All rights reserved.
//

#import "FLWAsynImageView.h"
#import "FLWHTTPRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#import "FLWRequestQueue.h"
#import "DataProcessor.h"
#import "ByteDataReader.h"
#define CACHE_IMAGE_DIR @"/Library/Caches/FLWCACHEIMAGES/"
#define CHANGE_IMAGE_TIME 0.3
@interface FLWAsynImageView ()<FLWRequestQueueDelegate>
{
    UIImage                 *_loadFailedImage;
    uint                    _cacheTime;
    NSString                *_loaddingUrl;
}
@end

@implementation FLWAsynImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _cacheTime = 0;
    }
    return self;
}
- (void)dealloc{
    [_loadFailedImage release];
    [super dealloc];
}

- (void)setImageWithUrl:(NSString *)url andWaittingImage:(UIImage *)waittingImage andLoadFailedImage:(UIImage *)failedImage andCacheTime:(uint)cacheTime{
    _loaddingUrl = [url retain];
    _cacheTime = cacheTime;
    [_loadFailedImage release];
    _loadFailedImage = nil;
    _loadFailedImage = [[UIImage alloc]initWithCGImage:failedImage.CGImage];
    if (url.length == 0) {
        [self setImage:failedImage];
        return;
    }
    else{
        [self setImage:waittingImage];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *path = [self pathOfCacheImageWithUrl:[NSURL URLWithString:url]];
        if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
            NSData *data = [NSData dataWithContentsOfFile:path];
            uint furTime = [ByteDataReader readUnsignedInt:[data bytes] startIndex:0 byteEndian:BYTEORDER_LITTLE_ENDIAN];
            if (furTime == 0 || ![self cacheExpired:furTime]) {
                UIImage *image =[UIImage imageWithData:[data subdataWithRange:NSMakeRange(sizeof(uint), data.length - sizeof(uint))]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setImage:image];
                });
                
            }
            else{
                NSError *error = nil;
                [[NSFileManager defaultManager]removeItemAtPath:path error:&error];//图片缓存过期
                if (nil != error) {
                    NSLog(@"imageDeleteError = %@",error.userInfo);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[FLWRequestQueue defaultQueue]addRequestToQueue:url andResponser:self  andTimeOut:0];
                });
            }
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[FLWRequestQueue defaultQueue]addRequestToQueue:url andResponser:self  andTimeOut:0];
            });
        }
    });
}

- (void)setImageWithAnimation:(UIImage *)image{
    CATransition *transition = [CATransition animation];
    transition.duration = CHANGE_IMAGE_TIME;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.layer addAnimation:transition forKey:@"changeImageAnimation"];
    [super setImage:image];
}
#pragma mark -
#pragma mark -FLWRequestQueue下载成功后的回调

- (void)flwDownLoadSuccessed:(NSData *)data url:(NSString *)url{
    if (![url isEqualToString:_loaddingUrl]) {
        return;
    }
    UIImage *image = [UIImage imageWithData:data];
    if (nil != image) {
        [self setImageWithAnimation:image];
        [self cacheImageWithUrl:[NSURL URLWithString:url] andData:data];
    }
    else{
        [self setImageWithAnimation:_loadFailedImage];
    }
}

#pragma mark -
#pragma mark -辅助方法

- (NSString *)pathOfCacheImageWithUrl:(NSURL *)url{     // 获取图片缓存地址
    NSString *strUrl = [NSString stringWithString:[url absoluteString]];
    NSString *path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),CACHE_IMAGE_DIR];
    NSArray *array = [strUrl pathComponents];
    for (NSString *str in array) {
        path = [path stringByAppendingString:str];
    }
    //    NSLog(@"imageNamePath = %@",path);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",NSHomeDirectory(),CACHE_IMAGE_DIR]])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager]createDirectoryAtPath:[NSString stringWithFormat:@"%@%@",NSHomeDirectory(),CACHE_IMAGE_DIR] withIntermediateDirectories:NO attributes:nil error:&error];
        if (nil != error) {
            NSLog(@"%@",error);
        }
    }
    return path;
}

- (void)cacheImageWithUrl:(NSURL *)url andData:(NSData *)data{     // 将获取的Data缓存到本地
    NSString *path = [self pathOfCacheImageWithUrl:url];
    uint furtherTime = 0;
    if (_cacheTime != 0) {
        furtherTime = (uint)[[NSDate date] timeIntervalSince1970] + _cacheTime;
    }
    const void *bytes = uintToByte(furtherTime, BYTEORDER_LITTLE_ENDIAN);
    NSMutableData *withTimeData = [NSMutableData dataWithBytes:bytes length:sizeof(uint)];
    [withTimeData appendData:data];
    //    [withTimeData writeToFile:path atomically:YES];
    NSError *error = nil;
    [withTimeData writeToFile:path options:NSDataWritingAtomic error:&error];
    if (nil != error) {
        NSLog(@"%@",error);
    }
}

- (BOOL)cacheExpired:(uint)time{       //判断缓存是否过期
    uint nowTime = (uint)[[NSDate date] timeIntervalSince1970];
    return nowTime > time ? YES : NO;
}



@end
