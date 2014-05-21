//
//  FLWAsynchronous.m
//  FLWNetWork
//
//  Created by LW on 14-3-11.
//  Copyright (c) 2014年 Liuwei.fan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProcessor.h"

@interface ByteDataReader : NSObject

+ (uint)readUnsignedInt:(const void*)bytes startIndex:(int)index byteEndian:(enum Endian)endian;
+ (ushort)readUnsignedShort:(const void*)bytes startIndex:(int)index  byteEndian:(enum Endian)endian;
+ (Byte)readByte:(const void*)bytes startIndex:(int)index;
+ (NSString*)readUTF8String:(const void*)bytes startIndex:(int)index readCount:(int)count;
+ (NSString*)readUnicodeString:(const void*)bytes startIndex:(int)index readCount:(int)count;
+ (NSData *)Utf8ToUnicodeBytes:(NSData *)data;
+ (NSData *)Utf8ToUnicodeBytes2:(NSData *)data;

@end
