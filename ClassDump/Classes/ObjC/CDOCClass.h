// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDOCProtocol.h>
#import <ClassDump/CDTopologicalSortProtocol.h>
#import <Foundation/Foundation.h>

@class CDOCClassReference, CDOCInstanceVariable;

@interface CDOCClass : CDOCProtocol <CDTopologicalSort>

@property (strong) CDOCClassReference *superClassRef;
@property (copy, readonly) NSString *superClassName;
@property (strong) NSArray<CDOCInstanceVariable *> *instanceVariables;
@property (strong, readonly) NSOrderedSet<NSString *> *instancePropertySynthesizedIvarNames;
@property (assign) BOOL isExported;
@property (assign) BOOL isSwiftClass;

@end
