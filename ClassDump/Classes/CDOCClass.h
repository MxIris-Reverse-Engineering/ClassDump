// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>
#import "CDOCProtocol.h"
#import "CDTopologicalSortProtocol.h"

@class CDOCClassReference, CDOCInstanceVariable;

@interface CDOCClass : CDOCProtocol <CDTopologicalSort>

@property (strong) CDOCClassReference *superClassRef;
@property (copy, readonly) NSString *superClassName;
@property (strong) NSArray<CDOCInstanceVariable *> *instanceVariables;
@property (assign) BOOL isExported;
@property (assign) BOOL isSwiftClass;

@end
