// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDLCFunctionStarts.h>

#import <ClassDump/ULEB128.h>
#import <ClassDump/ClassDumpUtils.h>
@implementation CDLCFunctionStarts
{
    NSArray *_functionStarts;
}

#pragma mark -

- (NSArray *)functionStarts;
{
    if (_functionStarts == nil) {
        NSData *functionStartsData = [self linkeditData];
        const uint8_t *start = (uint8_t *)[functionStartsData bytes];
        const uint8_t *end = start + [functionStartsData length];
        uint64_t startAddress;
        uint64_t previousAddress = 0;
        NSMutableArray *functionStarts = [[NSMutableArray alloc] init];
        while ((startAddress = read_uleb128(&start, end))) {
            [functionStarts addObject:@(startAddress + previousAddress)];
            previousAddress += startAddress;
        }
        _functionStarts = [functionStarts copy];
    }
    return _functionStarts;
}

@end
