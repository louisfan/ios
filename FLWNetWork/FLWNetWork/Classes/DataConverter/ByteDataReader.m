//
//  ByteDataReader.m
//  NetworkService
//
//  Created by 刘璨 on 13-4-8.
//  Copyright (c) 2013年 刘璨. All rights reserved.
//

#import "ByteDataReader.h"

@implementation ByteDataReader

+ (uint)readUnsignedInt:(const void*)bytes startIndex:(int)index byteEndian:(enum Endian)endian {
    uint result = 0;
    int byteCount = sizeof(uint);
    Byte* bytePtr = (Byte*)bytes;
    if (endian == BYTEORDER_BIG_ENDIAN) {
        for (int i=0; i<byteCount; i++) {
            result += bytePtr[index+i];
            if (i != byteCount-1) {
                result = result<<8;
            }
        }
    } else if (endian == BYTEORDER_LITTLE_ENDIAN) {
        for (int i=0; i<byteCount; i++) {
            result += bytePtr[index+byteCount-1-i];
            if (i != byteCount-1) {
                result = result<<8;
            }
        }
    }
    return result;
}

+ (ushort)readUnsignedShort:(const void *)bytes startIndex:(int)index byteEndian:(enum Endian)endian {
    ushort result = 0;
    int byteCount = sizeof(ushort);
    Byte* bytePtr = (Byte*)bytes;
    if (endian == BYTEORDER_BIG_ENDIAN) {
        for (int i=0; i<byteCount; i++) {
            result += bytePtr[index+i];
            if (i != byteCount-1) {
                result = result<<8;
            }
        }
    } else {
        for (int i=0; i<byteCount; i++) {
            result += bytePtr[index+byteCount-1-i];
            if (i != byteCount-1) {
                result = result<<8;
            }
        }
    }
    return result;
}

+ (Byte)readByte:(const void *)bytes startIndex:(int)index {
    Byte* bytePtr = (Byte*)bytes;
    return bytePtr[index];
}

+ (NSString*)readUTF8String:(const void *)bytes startIndex:(int)index readCount:(int)count {
    NSString* utf8String = [[NSString alloc] initWithBytes:bytes+index length:count encoding:NSUTF8StringEncoding];
    return [utf8String autorelease];
}

+ (NSString*)readUnicodeString:(const void *)bytes startIndex:(int)index readCount:(int)count {
    NSString* unicString = [[NSString alloc] initWithBytes:bytes+index length:count encoding:NSUnicodeStringEncoding];
    return [unicString autorelease];
}

+ (NSData *)Utf8ToUnicodeBytes:(NSData *)data {
    NSMutableData *unicData = [[NSMutableData alloc] initWithData:data];
    Byte *utf8Bytes = (Byte *)[data bytes];
    int currPos = 0;
    int unicBytesCnt = 0;
    while (currPos < data.length) {
        unichar _char;
        int utfBytesCnt = encUtf8ToUnicode(utf8Bytes+currPos, &_char);
        if (utfBytesCnt == 0) {
            [unicData setLength:unicBytesCnt];
            return unicData;
        } else {
            [unicData replaceBytesInRange:NSMakeRange(unicBytesCnt, 2) withBytes:&_char length:2];
            currPos += utfBytesCnt;
            unicBytesCnt += 2;
        }
    }
    [unicData setLength:unicBytesCnt];
    return unicData;
}

+ (NSData *)Utf8ToUnicodeBytes2:(NSData *)data {
    NSMutableData *unicData = [[NSMutableData alloc] initWithData:data];
    Byte *utf8Bytes = (Byte *)[data bytes];
    int currPos = 0;
    int unicBytesCnt = 0;
    while (currPos < data.length) {
        unichar _char;
        int utfBytesCnt = encUtf8ToUnicode(utf8Bytes+currPos, &_char);
        if (utfBytesCnt == 0) {
            return unicData;
        } else {
            [unicData replaceBytesInRange:NSMakeRange(unicBytesCnt, 2) withBytes:&_char length:2];
            currPos += utfBytesCnt;
            unicBytesCnt += 2;
        }
    }
    return unicData;
}



@end
