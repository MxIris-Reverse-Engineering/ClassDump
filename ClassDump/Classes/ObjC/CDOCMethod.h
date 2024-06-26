// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>

@class CDTypeController;

@interface CDOCMethod : NSObject <NSCopying>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithName:(NSString *)name typeString:(NSString *)typeString;
- (instancetype)initWithName:(NSString *)name typeString:(NSString *)typeString address:(NSUInteger)address;

@property (readonly) NSString *name;
@property (readonly) NSString *typeString;
@property (assign) NSUInteger address;

- (NSArray *)parsedMethodTypes;

- (void)appendToString:(NSMutableString *)resultString typeController:(CDTypeController *)typeController;

- (NSComparisonResult)ascendingCompareByName:(CDOCMethod *)other;

@end
