//
//  DataProcessor.c
//  NetworkService
//
//  Created by 刘璨 on 13-4-1.
//  Copyright (c) 2013年 刘璨. All rights reserved.
//

#include <stdlib.h>
#include "DataProcessor.h"

void* intToByte(int num, enum Endian endian) {
    int byteCount = sizeof(num);
    unsigned char *bytes = malloc(byteCount);
    for (int i=0; i<byteCount; i++) {
        if (endian == BYTEORDER_BIG_ENDIAN) {
            bytes[byteCount-1-i] = num&0xFF;
            num = num>>8;
        } else if (endian == BYTEORDER_LITTLE_ENDIAN) {
            bytes[i] = num&0xFF;
            num = num>>8;
        }
    }
    return bytes;
}

void* uintToByte(uint num, enum Endian endian) {
    int byteCount = sizeof(num);
    unsigned char *bytes = malloc(byteCount);
    for (int i=0; i<byteCount; i++) {
        if (endian == BYTEORDER_BIG_ENDIAN) {
            bytes[byteCount-1-i] = num&0xFF;
            num = num>>8;
        } else if (endian == BYTEORDER_LITTLE_ENDIAN) {
            bytes[i] = num&0xFF;
            num = num>>8;
        }
    }
    return bytes;
}

void* shortToByte(short num, enum Endian endian) {
    int byteCount = sizeof(num);
    unsigned char *bytes = malloc(byteCount);
    for (int i=0; i<byteCount; i++) {
        if (endian == BYTEORDER_BIG_ENDIAN) {
            bytes[byteCount-1-i] = num&0xFF;
            num = num>>8;
        } else if (endian == BYTEORDER_LITTLE_ENDIAN) {
            bytes[i] = num&0xFF;
            num = num>>8;
        }
    }
    return bytes;
}

int encUtf8ToUnicode(const unsigned char* pInput, unsigned short *Unic) {

    // b1 表示UTF-8编码的pInput中的高字节, b2 表示次高字节, ...
    char b1, b2, b3, b4, b5, b6;
    
    *Unic = 0x0; // 把 *Unic 初始化为全零
    int utfbytes = getUtf8Size(*pInput);
    unsigned char *pOutput = (unsigned char *) Unic;
    
    switch ( utfbytes )
    {
        case 0:
            *pOutput     = *pInput;
            
            utfbytes    += 1;
            break;
        case 1:
            if (*pInput == '\0') {
                return 0;
            }
            *pOutput     = *pInput;
            break;
        case 2:
            b1 = *pInput;
            b2 = *(pInput + 1);
            if ( (b2 & 0xC0) != 0x80 )
                return 0;
            *pOutput     = (b1 << 6) + (b2 & 0x3F);
            *(pOutput+1) = (b1 >> 2) & 0x07;
            break;
        case 3:
            b1 = *pInput;
            b2 = *(pInput + 1);
            b3 = *(pInput + 2);
            if ( ((b2 & 0xC0) != 0x80) || ((b3 & 0xC0) != 0x80) )
                return 0;
            *pOutput     = (b2 << 6) + (b3 & 0x3F);
            *(pOutput+1) = (b1 << 4) + ((b2 >> 2) & 0x0F);
            break;
        case 4:
            b1 = *pInput;
            b2 = *(pInput + 1);
            b3 = *(pInput + 2);
            b4 = *(pInput + 3);
            if ( ((b2 & 0xC0) != 0x80) || ((b3 & 0xC0) != 0x80)
                || ((b4 & 0xC0) != 0x80) )
                return 0;
            *pOutput     = (b3 << 6) + (b4 & 0x3F);
            *(pOutput+1) = (b2 << 4) + ((b3 >> 2) & 0x0F);
            *(pOutput+2) = ((b1 << 2) & 0x1C)  + ((b2 >> 4) & 0x03);
            break;
        case 5:
            b1 = *pInput;
            b2 = *(pInput + 1);
            b3 = *(pInput + 2);
            b4 = *(pInput + 3);
            b5 = *(pInput + 4);
            if ( ((b2 & 0xC0) != 0x80) || ((b3 & 0xC0) != 0x80)
                || ((b4 & 0xC0) != 0x80) || ((b5 & 0xC0) != 0x80) )
                return 0;
            *pOutput     = (b4 << 6) + (b5 & 0x3F);
            *(pOutput+1) = (b3 << 4) + ((b4 >> 2) & 0x0F);
            *(pOutput+2) = (b2 << 2) + ((b3 >> 4) & 0x03);
            *(pOutput+3) = (b1 << 6);
            break;
        case 6:
            b1 = *pInput;
            b2 = *(pInput + 1);
            b3 = *(pInput + 2);
            b4 = *(pInput + 3);
            b5 = *(pInput + 4);
            b6 = *(pInput + 5);
            if ( ((b2 & 0xC0) != 0x80) || ((b3 & 0xC0) != 0x80)
                || ((b4 & 0xC0) != 0x80) || ((b5 & 0xC0) != 0x80)
                || ((b6 & 0xC0) != 0x80) )
                return 0;
            *pOutput     = (b5 << 6) + (b6 & 0x3F);
            *(pOutput+1) = (b5 << 4) + ((b6 >> 2) & 0x0F);
            *(pOutput+2) = (b3 << 2) + ((b4 >> 4) & 0x03);
            *(pOutput+3) = ((b1 << 6) & 0x40) + (b2 & 0x3F);
            break;
        default:
            return 0;
            break;
    }
    
    return utfbytes;
}

int getUtf8Size(const unsigned char utf8_char) {
    int utfbytes = 0;
    if (utf8_char >> 7 == 0) {
        utfbytes = 1;
    } else if ((utf8_char & 0xfc) == 0xfc) {
        utfbytes = 6;
    } else if ((utf8_char & 0xf8) == 0xf8) {
        utfbytes = 5;
    } else if ((utf8_char & 0xf0) == 0xf0) {
        utfbytes = 4;
    } else if ((utf8_char & 0xe0) == 0xe0) {
        utfbytes = 3;
    } else if ((utf8_char & 0xc0) == 0xc0) {
        utfbytes = 2;
    }
    return utfbytes;
}


