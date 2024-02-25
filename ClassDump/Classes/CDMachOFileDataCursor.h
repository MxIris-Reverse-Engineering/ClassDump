// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>
#import "CDDataCursor.h"

@class CDMachOFile, CDSection;

@interface CDMachOFileDataCursor : CDDataCursor

@property (nonatomic, readonly, strong) CDMachOFile *machOFile;

- (instancetype)initWithFile:(CDMachOFile *)machOFile;
- (instancetype)initWithFile:(CDMachOFile *)machOFile offset:(NSUInteger)offset;
- (instancetype)initWithFile:(CDMachOFile *)machOFile address:(NSUInteger)address;

- (id)initWithSection:(CDSection *)section;

- (void)setAddress:(NSUInteger)address;

// Read using the current byteOrder
- (uint16_t)readInt16;
- (uint32_t)readInt32;
- (uint64_t)readInt64;

- (uint32_t)peekInt32;

// Read using the current byteOrder and ptrSize (from the machOFile)
- (uint64_t)readPtr;
- (uint64_t)readPtr:(bool)small;
- (uint64_t)peekPtr;
- (uint64_t)peekPtr:(bool)small;
@end
