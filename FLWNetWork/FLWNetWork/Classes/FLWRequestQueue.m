//
//  FLWRequestQueue.m
//  FLWNetWork
//
//  Created by LW on 14-3-27.
//  Copyright (c) 2014年 Liuwei.fan. All rights reserved.
//

#import "FLWRequestQueue.h"
#import "FLWHTTPRequest.h"
#define RESPONSERKEY    @"responser"
#define SELECTORKEY     @"selector"
@interface FLWRequestQueue (Private)
- (void)loadFinishWithOpretion:(FlwRequestOpretion *)opretion andData:(NSData *)data andResult:(BOOL)isSuccessed;
@end

#pragma mark -
#pragma mark -网络请求块

@interface FlwRequestOpretion :NSObject
{
    FLWHTTPRequest  *_request;
    NSString        *_url;
    NSMutableArray  *_responserArray;
    double          _timeOut;
}
@property(nonatomic,retain)NSMutableArray   *responserArray;
@property(nonatomic,retain)NSString         *url;
@property(nonatomic,assign)double           timeOut;
- (id)initWithUrl:(NSString *)url andResponser:(id)responser ;
- (void)addResponser:(id)responser ;
- (void)removeResponser:(id)responser;
- (void)startRequest;
- (void)cancel;
@end

@implementation FlwRequestOpretion
@synthesize url = _url,responserArray = _responserArray,timeOut = _timeOut;

- (id)initWithUrl:(NSString *)url andResponser:(id)responser{
    self = [super init];
    if (self) {
        _url = [[NSString alloc]initWithString:url];
        _timeOut = 0;
        if (_responserArray == nil) {
            _responserArray = [[NSMutableArray alloc]init];
        }
        [self addResponser:responser];
    }
    return self;
}
- (void)removeResponser:(id)responser{
    for (NSDictionary *dic in _responserArray) {
        if ([dic objectForKey:RESPONSERKEY] == responser) {
            [_responserArray removeObject:dic];
            break;
        }
    }
}
- (void)cancel{
    [_request clearDelegateAndCancel];
}
- (void)addResponser:(id)responser{
    [_responserArray addObject:responser];
}

- (void)startRequest{
    _request = [[FLWHTTPRequest alloc]initWithUrl:_url andDelegate:self];
    [_request setDidFailedLoad:@selector(didFailedLoad:)];
    [_request setDidFinishedLoad:@selector(didFinishedLoad:)];
    [_request setTimeOut:_timeOut];
    _request.requestMethod = FLW_HTTP_REQUEST_METHOD_GET;
    [_request startRequest];
}
- (void)didFailedLoad:(FLWHTTPRequest *)req{
    [[FLWRequestQueue defaultQueue]loadFinishWithOpretion:self andData:nil andResult:NO];
}
- (void)didFinishedLoad:(FLWHTTPRequest *)req{
    [[FLWRequestQueue defaultQueue]loadFinishWithOpretion:self andData:[req resposeData] andResult:YES];
}
- (void)dealloc{
    [_request release];
    [_url release];
    [super dealloc];
}
@end

#pragma mark -
#pragma mark -网络请求队列管理

@interface FLWRequestQueue ()
{
    NSMutableArray  *_waitQueue;
    NSMutableArray  *_requestQueue;
    NSLock          *_queueLock;
    int             _maxSynCount;
}
@end

static FLWRequestQueue *me = nil;
@implementation FLWRequestQueue
@synthesize maxSynCount = _maxSynCount;
+ (FLWRequestQueue *)defaultQueue{
    if (me == nil) {
        me = [[FLWRequestQueue alloc]init];
    }
    return me;
}
+ (void)destroy{
    [me release];
    me = nil;
}

- (id)init{
    self = [super init];
    if (self) {
        _waitQueue = [[NSMutableArray alloc]init];
        _requestQueue = [[NSMutableArray alloc]init];
        _maxSynCount = 10;
    }
    return self;
}

- (void)dealloc{
    [_queueLock release];
    [_waitQueue release];
    [_requestQueue release];
    [super dealloc];
}
#pragma mark -
#pragma mark -改变最大同时请求数

- (void)setMaxSynCount:(int)maxSynCount{
    if (maxSynCount > _maxSynCount) { //如果新的最大并发数大于当前最大并发数。将正在等待的队列中的网络请求移动到并发队列中。直到移动完或者将并发队列充满。
        [_queueLock lock];
        int moveCount = maxSynCount - _maxSynCount;
        if (_waitQueue.count < moveCount) {
            moveCount = (int)_waitQueue.count;
        }
        for (int i = 0; i < moveCount; i++) {
            FlwRequestOpretion *opretion = (FlwRequestOpretion *)[_waitQueue firstObject];
            [_requestQueue addObject:opretion];
            [opretion startRequest];
            [_waitQueue firstObject];
        }
        [_queueLock unlock];
    }
    _maxSynCount = maxSynCount;
}

#pragma mark -
#pragma mark -网络请求管理：加入队列，移除某个响应对象，取消请求。

- (void)addRequestToQueue:(NSString *)url andResponser:(id)responser  andTimeOut:(double)timeOut{
    if (nil == _queueLock) {
        _queueLock = [[NSLock alloc]init];
    }
    [_queueLock lock];
    for (FlwRequestOpretion *opretion in _requestQueue) {
        if ([opretion.url isEqualToString:url]) {
            if (![opretion.responserArray containsObject:responser]) {
                [opretion addResponser:responser];
            }
            [_queueLock unlock];
            return;
        }
    }
    for (FlwRequestOpretion *opretion in _waitQueue) {
        if ([opretion.url isEqualToString:url]) {
            if (![opretion.responserArray containsObject:responser]) {
                [opretion addResponser:responser];
            }
            [_queueLock unlock];
            return;
        }
    }
    
    FlwRequestOpretion *opretion = [[FlwRequestOpretion alloc]initWithUrl:url andResponser:responser];
    opretion.timeOut = timeOut;
    if (_requestQueue.count <_maxSynCount) {
        [_requestQueue addObject:opretion];
        [opretion startRequest];
    }
    else{
        [_waitQueue addObject:opretion];
    }
    [opretion release];
    [_queueLock unlock];
}

- (void)cancelWithUrl:(NSString *)url andResponser:(id)responser{
    [_queueLock lock];
    for (FlwRequestOpretion *op in _requestQueue) {
        if ([op.url isEqualToString:url]) {
            if (op.responserArray.count == 1) {
                [op cancel];
                [_requestQueue removeObject:op];
            }
            else if(op.responserArray.count > 1){
                [op removeResponser:responser];
            }
            [_queueLock unlock];
            return;
        }
    }
    for (FlwRequestOpretion *op in _waitQueue) {
        if ([op.url isEqualToString:url]) {
            if (op.responserArray.count == 1) {
                [_requestQueue removeObject:op];
            }
            else if(op.responserArray.count > 1){
                [op removeResponser:responser];
            }
            [_queueLock unlock];
            return;
        }
    }
    [_queueLock unlock];
}
- (void)cancelWithUrl:(NSString *)url{
    for (FlwRequestOpretion *op in _requestQueue) {
        if ([op.url isEqualToString:url]) {
            [op cancel];
            [_requestQueue removeObject:op];
            break;
        }
    }
}

#pragma mark -
#pragma mark -网络请求结束回调

- (void)loadFinishWithOpretion:(FlwRequestOpretion *)opretion andData:(NSData *)data andResult:(BOOL)isSuccessed{
    if (isSuccessed) {
        for (id<FLWRequestQueueDelegate> responser in opretion.responserArray) {
            if ([responser respondsToSelector:@selector(flwDownLoadSuccessed:url:)]) {
                [responser flwDownLoadSuccessed:data url:opretion.url];
            }
        }
    }
    
    [_queueLock lock];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    [_requestQueue removeObject:opretion];
    [pool release];
    
    if (_waitQueue.count > 0 && _requestQueue.count < _maxSynCount) { //(_requestQueue.count > _maxSynCount):在程序中途缩小了maxSynCount时会有发生。这时，不会将等待队列中的请求加入到并发队列，而是等待并发队列请求数低于最大并发数时再将等待请求加入到并发队列。
        
        FlwRequestOpretion *opretion1 = (FlwRequestOpretion *)[_waitQueue firstObject];
        [_requestQueue addObject:opretion1];
        [_waitQueue removeObject:opretion1];
        [opretion1 startRequest];
    }
    [_queueLock unlock];
}
@end






