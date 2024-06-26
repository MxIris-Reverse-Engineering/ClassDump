// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>
#import <ClassDump/CDVisitor.h>

// This limits the output to methods matching the search string.  Some context is included, so that you can see which class, category, or protocol
// contains the method.

@interface CDFindMethodVisitor : CDVisitor

@property (strong) NSString *searchString;

@end
