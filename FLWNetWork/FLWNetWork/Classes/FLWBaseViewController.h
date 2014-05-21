//
//  FLWBaseViewController.h
//  FLWNetWork
//
//  Created by LW on 14-3-24.
//  Copyright (c) 2014年 Liuwei.fan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLWHTTPRequest.h"
@interface FLWBaseViewController : UIViewController

- (void)addFlwRequest:(FLWHTTPRequest *)request;
- (void)removeRequest:(FLWHTTPRequest *)request;
- (BOOL)hasRequestWithIdentify:(int)identify;
@end
