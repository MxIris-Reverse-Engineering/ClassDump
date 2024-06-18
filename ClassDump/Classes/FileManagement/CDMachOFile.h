// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDFile.h>
#import <Foundation/Foundation.h>
#include <mach/machine.h> // For cpu_type_t, cpu_subtype_t
#include <mach-o/loader.h>

typedef enum : NSUInteger {
    CDByteOrder_LittleEndian = 0,
    CDByteOrder_BigEndian = 1,
} CDByteOrder;

@class CDLCSegment;
@class CDLCBuildVersion, CDLCDyldInfo, CDLCDylib, CDMachOFile, CDLCSymbolTable, CDLCDynamicSymbolTable, CDLCVersionMinimum, CDLCSourceVersion, CDLCChainedFixups, CDLCExportTRIEData, CDLoadCommand;

@interface CDMachOFile : CDFile

@property (readonly) CDByteOrder byteOrder;

@property (readonly) uint32_t magic;
@property (readonly) cpu_type_t cputype;
@property (readonly) cpu_subtype_t cpusubtype;
@property (readonly) uint32_t filetype;
@property (readonly) uint32_t flags;

@property (readonly) cpu_type_t maskedCPUType;
@property (readonly) cpu_subtype_t maskedCPUSubtype;

@property (readonly) NSArray<__kindof CDLoadCommand *> *loadCommands;
@property (readonly) NSArray<__kindof CDLoadCommand *> *dylibLoadCommands;
@property (readonly) NSArray<__kindof CDLoadCommand *> *segments;
@property (readonly) NSArray<NSString *> *runPaths;
@property (readonly) NSArray<__kindof CDLoadCommand *> *runPathCommands;
@property (readonly) NSArray<__kindof CDLoadCommand *> *dyldEnvironment;
@property (readonly) NSArray<__kindof CDLoadCommand *> *reExportedDylibs;

@property (strong, readonly) CDLCSymbolTable *symbolTable;
@property (strong, readonly) CDLCDynamicSymbolTable *dynamicSymbolTable;
@property (strong, readonly) CDLCDyldInfo *dyldInfo;
@property (strong, readonly) CDLCExportTRIEData *exportsTrie;
@property (strong, readonly) CDLCChainedFixups *chainedFixups;
@property (strong, readonly) CDLCDylib *dylibIdentifier;
@property (strong, readonly) CDLCVersionMinimum *minVersionMacOSX;
@property (strong, readonly) CDLCVersionMinimum *minVersionIOS;
@property (strong, readonly) CDLCSourceVersion *sourceVersion;
@property (strong, readonly) CDLCBuildVersion *buildVersion;

@property (readonly) BOOL uses64BitABI;

- (NSUInteger)ptrSize;

- (NSString *)filetypeDescription;
- (NSString *)flagDescription;

- (CDLCSegment *)dataConstSegment;
- (CDLCSegment *)segmentWithName:(NSString *)segmentName;
- (CDLCSegment *)segmentContainingAddress:(NSUInteger)address;
- (NSString *)stringAtAddress:(NSUInteger)address;

- (NSUInteger)dataOffsetForAddress:(NSUInteger)address;

- (const void *)bytes;
- (const void *)bytesAtOffset:(NSUInteger)offset;

@property (readonly) NSString *importBaseName;

@property (readonly) BOOL isEncrypted;
@property (readonly) BOOL hasProtectedSegments;
@property (readonly) BOOL canDecryptAllSegments;

- (NSString *)loadCommandString:(BOOL)isVerbose;
- (NSString *)headerString:(BOOL)isVerbose;

@property (readonly) NSUUID *UUID;
@property (readonly) NSString *archName;

- (Class)processorClass;
- (void)logInfoForAddress:(NSUInteger)address;

- (NSString *)externalClassNameForAddress:(NSUInteger)address;
- (BOOL)hasRelocationEntryForAddress:(NSUInteger)address;

// Checks compressed dyld info on 10.6 or later.
- (BOOL)hasRelocationEntryForAddress2:(NSUInteger)address;
- (NSString *)externalClassNameForAddress2:(NSUInteger)address;

- (CDLCDylib *)dylibLoadCommandForLibraryOrdinal:(NSUInteger)ordinal;

@property (readonly) BOOL hasObjectiveC1Data;
@property (readonly) BOOL hasObjectiveC2Data;
@property (readonly) Class processorClass;

- (NSString *)entitlements;
- (NSDictionary *)entitlementsDictionary;
- (uint64_t)peekPtrAtOffset:(NSUInteger)offset ptrSize:(NSUInteger)ptr;
- (uint64_t)preferredLoadAddress;
- (uint64_t)fixupBasedAddress:(uint64_t)address;
@end
