//
//  FLWAsynchronous.h
//  FLWNetWork
//
//  Created by LW on 14-3-11.
//  Copyright (c) 2014年 Liuwei.fan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLWAsynImageView : UIImageView

/*
 url:图片的网络地址
 waittingImage:获取网络图片过程中显示的图片
 failedImage:获取网络图片失败中显示的图片
 cacheTime:缓存时间(cacheTime 默认为0 永久缓存)
 */
- (void)setImageWithUrl:(NSString *)url andWaittingImage:(UIImage *)waittingImage andLoadFailedImage:(UIImage *)failedImage andCacheTime:(uint)cacheTime;
@end
