// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/NSData-CDExtensions.h>

#import <CommonCrypto/CommonDigest.h>
#import <ClassDump/ClassDumpUtils.h>
@implementation NSData (CDExtensions)

- (NSString *)hexString;
{
    NSMutableString *str = [NSMutableString string];
    const uint8_t *ptr = [self bytes];
    for (NSUInteger index = 0; index < [self length]; index++) {
        [str appendFormat:@"%02x", *ptr++];
    }
    
    return str;
}

- (NSData *)SHA1Digest;
{
    NSParameterAssert([self length] <= UINT32_MAX);
    
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([self bytes], (CC_LONG)[self length], digest);
    
    return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

@end
