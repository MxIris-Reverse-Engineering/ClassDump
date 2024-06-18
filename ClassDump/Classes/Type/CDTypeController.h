// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>
#import <ClassDump/CDTypeFormatter.h>
@protocol CDTypeControllerDelegate;

@class CDClassDump, CDType, CDTypeFormatter, CDClassDumpConfiguration;

@interface CDTypeController : NSObject <CDTypeFormatterDelegate>

@property (strong, readonly) CDClassDumpConfiguration *configuration;

- (instancetype)initWithConfiguration:(CDClassDumpConfiguration *)configuration;

@property (weak) id <CDTypeControllerDelegate> delegate;

@property (readonly) CDTypeFormatter *ivarTypeFormatter;
@property (readonly) CDTypeFormatter *methodTypeFormatter;
@property (readonly) CDTypeFormatter *propertyTypeFormatter;
@property (readonly) CDTypeFormatter *structDeclarationTypeFormatter;

@property (readonly) BOOL shouldShowIvarOffsets;
@property (readonly) BOOL shouldShowMethodAddresses;
@property (readonly) BOOL targetArchUses64BitABI;

@property (readonly) BOOL hasUnknownFunctionPointers;
@property (readonly) BOOL hasUnknownBlocks;

//- (CDType *)typeFormatter:(CDTypeFormatter *)typeFormatter replacementForType:(CDType *)type;
//- (NSString *)typeFormatter:(CDTypeFormatter *)typeFormatter typedefNameForStructure:(CDType *)structureType level:(NSUInteger)level;
//- (void)typeFormatter:(CDTypeFormatter *)typeFormatter didReferenceClassName:(NSString *)name;
//- (void)typeFormatter:(CDTypeFormatter *)typeFormatter didReferenceProtocolNames:(NSArray *)names;

- (void)appendStructuresToString:(NSMutableString *)resultString;

// Phase 0 - initiated from -[CDClassDump registerTypes]
- (void)phase0RegisterStructure:(CDType *)structure usedInMethod:(BOOL)isUsedInMethod;

// Run phase 1+
- (void)workSomeMagic;

// Phase 1
- (void)phase1RegisterStructure:(CDType *)structure;

- (void)endPhase:(NSUInteger)phase;

- (CDType *)phase2ReplacementForType:(CDType *)type;

- (void)phase3RegisterStructure:(CDType *)structure;
- (CDType *)phase3ReplacementForType:(CDType *)type;

- (BOOL)shouldShowName:(NSString *)name;
- (BOOL)shouldExpandType:(CDType *)type;
- (NSString *)typedefNameForType:(CDType *)type;

#pragma mark -
// Phase 0
- (void)phase:(NSUInteger)phase type:(CDType *)type usedInMethod:(BOOL)isUsedInMethod;

// Phase 1
- (void)phase1RegisterStructuresWithType:(CDType *)type;

// Phase 2
- (void)phase2MergeWithType:(CDType *)type;

// Phase 3
- (void)phase3RegisterWithType:(CDType *)type;
- (void)phase3RegisterMembersWithType:(CDType *)type;
- (void)phase3MergeWithType:(CDType *)type;

@end

#pragma mark -

@protocol CDTypeControllerDelegate <NSObject>
@optional
- (void)typeController:(CDTypeController *)typeController didReferenceClassName:(NSString *)name;
- (void)typeController:(CDTypeController *)typeController didReferenceProtocolNames:(NSArray *)names;
@end
