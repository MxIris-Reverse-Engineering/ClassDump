// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>

@class CDType, CDTypeController;

@interface CDTypeFormatter : NSObject

@property (weak) CDTypeController *typeController;

@property NSUInteger baseLevel;
@property BOOL shouldExpand;
@property BOOL shouldAutoExpand;
@property BOOL shouldShowLexing;
@property (readonly) BOOL shouldUseBOOLTypedef;
@property (readonly) BOOL shouldUseNSIntegerTypedef;
@property (readonly) BOOL shouldUseNSUIntegerTypedef;

- (NSString *)formatVariable:(NSString *)name type:(CDType *)type;
- (NSString *)formatMethodName:(NSString *)name typeString:(NSString *)typeString;
- (NSString *)typedefNameForStructure:(CDType *)structureType level:(NSUInteger)level;

- (void)formattingDidReferenceClassName:(NSString *)name;
- (void)formattingDidReferenceProtocolNames:(NSArray *)names;

@end
