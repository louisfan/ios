//
//  FLWBaseView.m
//  FLWNetWork
//
//  Created by LW on 14-3-24.
//  Copyright (c) 2014年 Liuwei.fan. All rights reserved.
//

#import "FLWBaseView.h"

@interface FLWBaseView ()
{
@private
    NSMutableArray *_requestArray;
}
@end

@implementation FLWBaseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc{
    for (FLWHTTPRequest *req in _requestArray) { //clear requests' delegate and cancel requests when release the View
        [req clearDelegateAndCancel];
    }
    [_requestArray release];
    [super dealloc];
}
- (void)clearRequests{
    for (FLWHTTPRequest *req in _requestArray) {
        [req clearDelegateAndCancel];
    }
}
- (void)addFlwRequest:(FLWHTTPRequest *)request{
    if (_requestArray == nil) {
        _requestArray = [[NSMutableArray alloc]init];
    }
    @synchronized(_requestArray){
        [_requestArray addObject:request];
    }
}
- (void)removeRequest:(FLWHTTPRequest *)request{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    @synchronized(_requestArray){
        [request clearDelegateAndCancel];
        if ([_requestArray containsObject:request]) {
            [_requestArray removeObject:request];
        }
    }
    [pool release];
    
}
@end
