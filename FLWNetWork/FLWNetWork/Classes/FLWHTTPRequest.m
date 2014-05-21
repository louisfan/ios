//
//  FLWHTTPRequest.m
//  FLWNetWork
//
//  Created by LW on 14-3-11.
//  Copyright (c) 2014年 Liuwei.fan. All rights reserved.
//
#define REQUEST_ERROR_MSG_POSTVALUE_ERROR @"postValue不能为空"
#import "FLWHTTPRequest.h"
@interface FLWHTTPRequest()
{
    SEL                             _didFinishedLoad;
    SEL                             _didFailedLoad;
    SEL                             _showPersent;
    
    FLW_HTTP_REQUEST_METHOD         _requestMethod;
    
    NSURLConnection                 *_connect;
    NSURL                           *_url;
    NSMutableData                   *_cacheData;
    id                              _delegate;
    NSMutableData                   *_responseData;
    CGFloat                         _totalLength;
    FLW_HTTP_REQUEST_CACHE_METHOD   _cacheMode;
    NSTimeInterval                  _timeOut;
    NSString                        *_errorMsg;
}
@end
@implementation FLWHTTPRequest
@synthesize didFailedLoad = _didFailedLoad,didFinishedLoad = _didFinishedLoad,requestMethod = _requestMethod,resposeData = _responseData,url = _url,showPersent = _showPersent,cacheMode = _cacheMode,timeOut = _timeOut,errorMsg = _errorMsg,identifier;

- (id)initWithUrl:(NSString *)url andDelegate:(id)delegate{
    self =[self init];
    if (self) {
        _url = [[NSURL alloc]initWithString:url];
        _delegate = delegate;
        self.identifier = 0;
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        _cacheMode = FLW_HTTP_REQUEST_CACHE_METHOD_IgnoringCacheData;
        _requestMethod = FLW_HTTP_REQUEST_METHOD_POST;
        _timeOut = 10;
    }
    return self;
}

- (void)setTimeOut:(NSTimeInterval)timeOut{
    _timeOut = timeOut;
}

- (void)setPostValue:(NSString *)value forKey:(NSString *)key{
    if (value.length==0) {
        NSLog(@"请输入正确的postValue,errormessage:%@",REQUEST_ERROR_MSG_POSTVALUE_ERROR);
        return;
    }
    if (_postVales == nil) {
        _postVales = [[NSMutableArray alloc]init];
    }
    for (NSMutableDictionary *dic in _postVales) {
        if ([[[dic allKeys] firstObject] isEqualToString:key]) {
            [dic setObject:value forKey:key];
            return;
        }
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:value forKey:key];
    [_postVales addObject:dic];
}

- (void)dealloc{
    [self clearDelegateAndCancel];
    [_cacheData release];
    [_responseData release];
    [_url release];
    [_connect release];
    [_postVales release];
    [super dealloc];
}
- (void)startRequest{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:_url];
    if (_requestMethod == FLW_HTTP_REQUEST_METHOD_POST) {
        [request setHTTPMethod:@"POST"];
        NSString *bodyString = @"";
        int i = 0;
        for (NSDictionary *dic in _postVales) {
            if(i == _postVales.count -1){
                bodyString = [bodyString stringByAppendingString:[NSString stringWithFormat:@"%@=%@",[[dic allKeys] firstObject],[[dic allValues] firstObject]]];
            }
            else{
                bodyString = [bodyString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",[[dic allKeys] firstObject],[[dic allValues] firstObject]]];
            }
            i++;
        }
        NSData *httpBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:httpBody];
    }
    else{
        [request setHTTPMethod:@"GET"];
    }
    request.cachePolicy = _cacheMode;
    _connect = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [request release];
    [_connect start];
    if (_timeOut != 0) {
        if (![[NSThread currentThread]isMainThread]) {
            [self performSelectorOnMainThread:@selector(createTimeOut) withObject:nil waitUntilDone:YES];
        }
        else{
            [self createTimeOut];
        }
    }
    
}

- (void)createTimeOut{
    [self performSelector:@selector(loadTimeOut)  withObject:nil afterDelay:_timeOut];
}

- (void)loadTimeOut{
    _errorMsg = @"timeOut";
    if (_delegate && [_delegate respondsToSelector:_didFailedLoad]) {
        [_delegate performSelector:_didFailedLoad withObject:self];
    }
    [self clearDelegateAndCancel];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadTimeOut) object:nil];
    
}

- (void)clearDelegateAndCancel{
    [_cacheData release];
    _cacheData = nil;
    _delegate = nil;
    [_connect cancel];
}


#pragma mark -NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _totalLength = response.expectedContentLength;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if (_cacheData == nil) {
        _cacheData = [[NSMutableData alloc]init];
    }
    [_cacheData appendData:data];
    if (_totalLength != 0 && _totalLength >= _cacheData.length && _showPersent != nil && _delegate != nil && [_delegate respondsToSelector:_showPersent]) {
        [_delegate performSelector:_showPersent withObject:[NSNumber numberWithFloat:_cacheData.length/_totalLength]];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadTimeOut) object:nil];
    _responseData = [[NSMutableData alloc]initWithData:_cacheData];
    if (_delegate && [_delegate respondsToSelector:_didFinishedLoad]) {
        [_delegate performSelector:_didFinishedLoad withObject:self];
    }
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadTimeOut) object:nil];
    if (_delegate && [_delegate respondsToSelector:_didFailedLoad]) {
        [_delegate performSelector:_didFailedLoad withObject:self];
    }
    
}
@end
