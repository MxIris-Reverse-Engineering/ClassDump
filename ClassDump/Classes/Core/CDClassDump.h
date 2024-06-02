// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDClassDumpVisitor.h>
#import <ClassDump/CDFatArch.h>
#import <ClassDump/CDFatFile.h>
#import <ClassDump/CDFile.h>
#import <ClassDump/CDFile.h> // For CDArch
#import <ClassDump/CDFindMethodVisitor.h>
#import <ClassDump/CDMachOFile.h>
#import <ClassDump/CDMultiFileVisitor.h>
#import <ClassDump/CDSearchPathState.h>
#import <Foundation/Foundation.h>
#include <mach-o/arch.h>

#define CLASS_DUMP_BASE_VERSION "4.2.0 (64 bit)"

#ifdef DEBUG
#define CLASS_DUMP_VERSION      CLASS_DUMP_BASE_VERSION " (iOS port by DreamDevLost, Updated by Kevin Bradley.)(Debug version compiled " __DATE__ " " __TIME__ ")"
#else
#define CLASS_DUMP_VERSION      CLASS_DUMP_BASE_VERSION
#endif

@class CDFile;
@class CDTypeController;
@class CDVisitor;
@class CDSearchPathState;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

extern NSString *CDErrorDomain_ClassDump;
extern NSString *CDErrorKey_Exception;

@interface CDClassDump : NSObject

@property BOOL shouldProcessRecursively;
@property BOOL shouldSortClasses;
@property BOOL shouldSortClassesByInheritance;
@property BOOL shouldSortMethods;
@property BOOL shouldShowIvarOffsets;
@property BOOL shouldShowMethodAddresses;
@property BOOL shouldShowHeader;
@property BOOL shouldStripOverrideMethods;
@property BOOL verbose;
@property BOOL stopAfterPreProcessor;
@property BOOL shallow;
@property BOOL dumpEntitlements;
@property CDArch targetArch;
@property (strong) NSRegularExpression *regularExpression;
@property (strong) NSString *sdkRoot;
@property (readonly) NSArray *machOFiles;
@property (readonly) NSArray *objcProcessors;
@property (readonly) BOOL containsObjectiveCData;
@property (readonly) BOOL hasEncryptedFiles;
@property (readonly) BOOL hasObjectiveCRuntimeInfo;
@property (readonly) CDTypeController *typeController;
@property (readonly) CDSearchPathState *searchPathState;

- (BOOL)loadFile:(CDFile *)file error:(NSError **)error;
- (void)processObjectiveCData;

- (void)recursivelyVisit:(CDVisitor *)visitor;

- (void)appendHeaderToString:(NSMutableString *)resultString;

- (void)registerTypes;

- (BOOL)shouldShowName:(NSString *)name;
- (void)showHeader;
- (void)showLoadCommands;

+ (BOOL)printFixupData;
+ (BOOL)performClassDumpOnFile:(NSString *)file withEntitlements:(BOOL)dumpEnt toFolder:(NSString *)outputPath error:(NSError **)error;
+ (BOOL)performClassDumpOnFile:(NSString *)file toFolder:(NSString *)outputPath error:(NSError **)error;
+ (nullable CDClassDump *)classDumpInstanceFromFile:(NSString *)file;
+ (NSDictionary *)getFileEntitlements:(NSString *)file;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
