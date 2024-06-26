// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>

@class CDMachOFileDataCursor;
@class CDLCSegment;

@interface CDSection : NSObject

- (instancetype)initWithDataCursor:(CDMachOFileDataCursor *)cursor segment:(CDLCSegment *)segment;

@property (readonly, weak) CDLCSegment *segment;

@property (nonatomic, readonly) NSData *data;

@property (nonatomic, readonly) NSString *segmentName;
@property (nonatomic, readonly) NSString *sectionName;

@property (nonatomic, readonly) NSUInteger addr;
@property (nonatomic, readonly) NSUInteger size;

- (BOOL)containsAddress:(NSUInteger)address;
- (NSUInteger)fileOffsetForAddress:(NSUInteger)address;

@end
