// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>

@class CDOCCategory, CDOCClass;

@interface CDOCSymtab : NSObject

@property (readonly) NSArray *classes;
- (void)addClass:(CDOCClass *)aClass;

@property (readonly) NSArray *categories;
- (void)addCategory:(CDOCCategory *)category;

@end
