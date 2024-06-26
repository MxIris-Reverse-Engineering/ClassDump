// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>
#import <ClassDump/CDFile.h>

@class CDFatArch;

@interface CDFatFile : CDFile

@property (readonly) NSMutableArray<CDFatArch *> *arches;
@property (nonatomic, readonly) NSArray<NSString *> *archNames;

- (void)addArchitecture:(CDFatArch *)fatArch;
- (BOOL)containsArchitecture:(CDArch)arch;

@end
