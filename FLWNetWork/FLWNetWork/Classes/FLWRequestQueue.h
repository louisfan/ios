//
//  FLWRequestQueue.h
//  FLWNetWork
//
//  Created by LW on 14-3-27.
//  Copyright (c) 2014年 Liuwei.fan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLWHTTPRequest.h"
@class FlwRequestOpretion;
@interface FLWRequestQueue : NSObject
/*
 maxSynCount:同时发生的最大请求数.
 */
@property(nonatomic,assign)int maxSynCount;
+ (FLWRequestQueue *)defaultQueue;
+ (void)destroy;

- (void)addRequestToQueue:(NSString *)url andResponser:(id)responser  andTimeOut:(double)timeOut;
- (void)cancelWithUrl:(NSString *)url andResponser:(id)responser;
- (void)cancelWithUrl:(NSString *)url;

@end

@protocol FLWRequestQueueDelegate <NSObject>
@required
- (void)flwDownLoadSuccessed:(NSData *)data url:(NSString *)url;
@end
