// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>

@class CDType, CDTypeFormatter, CDTypeController, CDClassDumpConfiguration;

@protocol CDTypeFormatterDelegate <NSObject>

- (CDType *)typeFormatter:(CDTypeFormatter *)typeFormatter replacementForType:(CDType *)type;
- (NSString *)typeFormatter:(CDTypeFormatter *)typeFormatter typedefNameForStructure:(CDType *)structureType level:(NSUInteger)level;
- (void)typeFormatter:(CDTypeFormatter *)typeFormatter didReferenceClassName:(NSString *)name;
- (void)typeFormatter:(CDTypeFormatter *)typeFormatter didReferenceProtocolNames:(NSArray *)names;
- (BOOL)shouldExpandType:(CDType *)type;
//// TODO: (2009-08-26) Ideally, just formatting a type shouldn't change it.  These changes should be done before, but this is handy.
- (void)phase3MergeWithType:(CDType *)type;
@end


@interface CDTypeFormatter : NSObject

@property (weak) id<CDTypeFormatterDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConfiguration:(CDClassDumpConfiguration *)configuration;

@property NSUInteger baseLevel;
@property BOOL shouldExpand;
@property BOOL shouldAutoExpand;
@property BOOL shouldShowLexing;
@property (strong, readonly) CDClassDumpConfiguration *configuration;

- (NSString *)formatVariable:(NSString *)name type:(CDType *)type;
- (NSString *)formatMethodName:(NSString *)name typeString:(NSString *)typeString;
- (NSString *)typedefNameForStructure:(CDType *)structureType level:(NSUInteger)level;
- (NSString *)formattedString:(NSString *)previousName type:(CDType *)type level:(NSUInteger)level;
- (void)formattingDidReferenceClassName:(NSString *)name;
- (void)formattingDidReferenceProtocolNames:(NSArray *)names;

@end
