// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

// Importing these here saves us from importing them in the implementation of every load command.
#import <Foundation/Foundation.h>
#include <mach-o/loader.h>
#import <ClassDump/CDMachOFileDataCursor.h>

@class CDMachOFile;

@interface CDLoadCommand : NSObject

+ (id)loadCommandWithDataCursor:(CDMachOFileDataCursor *)cursor;

- (instancetype)initWithDataCursor:(CDMachOFileDataCursor *)cursor;

- (NSString *)extraDescription;

@property (readonly, weak) CDMachOFile *machOFile;
@property (readonly) NSUInteger commandOffset;

@property (nonatomic, readonly) uint32_t cmd;
@property (nonatomic, readonly) uint32_t cmdsize;
@property (nonatomic, readonly) BOOL mustUnderstandToExecute;

@property (nonatomic, readonly) NSString *commandName;

- (void)appendToString:(NSMutableString *)resultString verbose:(BOOL)isVerbose;

- (void)machOFileDidReadLoadCommands:(CDMachOFile *)machOFile;

@end
