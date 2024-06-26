// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>

@class CDType;

@interface CDStructureInfo : NSObject <NSCopying>

- (instancetype)initWithType:(CDType *)type;

- (NSString *)shortDescription;

@property (readonly) CDType *type;

@property (assign) NSUInteger referenceCount;
- (void)addReferenceCount:(NSUInteger)count;

@property (assign) BOOL isUsedInMethod;
@property (strong) NSString *typedefName;

- (void)generateTypedefName:(NSString *)baseName;

@property (nonatomic, readonly) NSString *name;

- (NSComparisonResult)ascendingCompareByStructureDepth:(CDStructureInfo *)other;
- (NSComparisonResult)descendingCompareByStructureDepth:(CDStructureInfo *)other;

@end
