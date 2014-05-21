//
//  FLWAsynchronous.m
//  FLWNetWork
//
//  Created by LW on 14-3-11.
//  Copyright (c) 2014年 Liuwei.fan. All rights reserved.
//

#ifndef NetworkService_DataProcessor_h
#define NetworkService_DataProcessor_h

#include <sys/types.h>

enum Endian {
    BYTEORDER_BIG_ENDIAN = 1,
    BYTEORDER_LITTLE_ENDIAN = 2
    };

void* intToByte(int num, enum Endian endian);
void* uintToByte(uint num, enum Endian endian);
void* shortToByte(short num, enum Endian endian);
int encUtf8ToUnicode(const unsigned char* pInput, unsigned short *Unic);
int getUtf8Size(const unsigned char utf8_char);

#endif
