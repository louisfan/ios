//
//  FLWBaseViewController.m
//  FLWNetWork
//
//  Created by LW on 14-3-24.
//  Copyright (c) 2014年 Liuwei.fan. All rights reserved.
//

#import "FLWBaseViewController.h"

@interface FLWBaseViewController ()
{
@private
    NSMutableArray *_requestArray;
}
@end

@implementation FLWBaseViewController

- (void)dealloc{
    for (FLWHTTPRequest *req in _requestArray) { //clear requests' delegate and cancel requests when release the ViewController
        [req clearDelegateAndCancel];
    }
    [_requestArray release];
    [super dealloc];
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
        if ([_requestArray containsObject:request]) {
            [_requestArray removeObject:request];
        }
    }
    [pool release];
    
}

- (BOOL)hasRequestWithIdentify:(int)identify{
    for (FLWHTTPRequest *req in _requestArray) {
        if (req.identifier == identify) {
            return YES;
        }
    }
    return NO;
}

@end
