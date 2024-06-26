// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>

@class CDType, CDTypeController;

@interface CDOCInstanceVariable : NSObject

- (instancetype)initWithName:(NSString *)name typeString:(NSString *)typeString offset:(NSUInteger)offset;

@property (readonly) NSString *name;
@property (readonly) NSString *typeString;
@property (readonly) NSUInteger offset;

// Lazily parses the typeString.  Returns nil and sets the parseError if parsing failed.  Does not try to parse again in the event of an error.
@property (readonly) CDType *type;

// This is set after the typeString has been parsed if there was an error.  Doesn't trigger parsing.
@property (readonly) NSError *parseError;

- (void)appendToString:(NSMutableString *)resultString typeController:(CDTypeController *)typeController;

@end
