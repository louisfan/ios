//
//  FLWHTTPRequest.h
//  FLWNetWork
//
//  Created by LW on 14-3-11.
//  Copyright (c) 2014年 Liuwei.fan. All rights reserved.
//
typedef enum _FLW_HTTP_REQUEST_METHOD{
    FLW_HTTP_REQUEST_METHOD_GET, //request With GET
    FLW_HTTP_REQUEST_METHOD_POST,//request with POST
}FLW_HTTP_REQUEST_METHOD;

typedef enum _FLW_HTTP_REQUEST_CACHE_METHOD{
    /*
     Older name for NSURLRequestReloadIgnoringLocalCacheData.
     */
    FLW_HTTP_REQUEST_CACHE_METHOD_IgnoringCacheData = NSURLRequestReloadIgnoringCacheData,
    
    /*
     Specifies that
     the existing cache data may be used provided the origin source
     confirms its validity, otherwise the URL is loaded from the
     origin source.  Unimplemented.
     */
    FLW_HTTP_REQUEST_CACHE_METHOD_RevalidatingCacheData = NSURLRequestReloadRevalidatingCacheData,
}FLW_HTTP_REQUEST_CACHE_METHOD;


#import <Foundation/Foundation.h>

@interface FLWHTTPRequest : NSObject
{
    NSMutableArray                          *_postVales;
}
@property(nonatomic)SEL                     showPersent;        //show the persent when downloading
@property(nonatomic)SEL                     didFinishedLoad;    //requestf inished call back
@property(nonatomic)SEL                     didFailedLoad;      //request failed call back
@property(nonatomic, retain)                NSURL *url;
@property(nonatomic, assign)                FLW_HTTP_REQUEST_CACHE_METHOD cacheMode;
@property(nonatomic, assign)                FLW_HTTP_REQUEST_METHOD requestMethod;
@property(nonatomic, readonly, retain)      NSData *resposeData;
@property(nonatomic, readonly)              NSString *errorMsg;
@property(nonatomic)                        NSTimeInterval timeOut;
@property(nonatomic, assign)                int identifier;
- (void)setPostValue:(NSString *)value forKey:(NSString *)key;
- (id)initWithUrl:(NSString *)url andDelegate:(id)delegate;
- (void)clearDelegateAndCancel; // you can call the method when you want to cancel the request
- (void)startRequest;

@end


