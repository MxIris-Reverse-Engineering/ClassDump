// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>
#import <ClassDump/CDVisitor.h>

// This builds up a dictionary mapping class names to a framework names.
// It is only used by CDMultipleFileVisitor to generate individual imports when creating separate header files.

// Some protocols appear in multiple frameworks.  This just records the last framework that contained a reference, which
// produces incorrect results.  For example, -r AppKit.framework, and Foundation.framework is processed before several
// others, including Symbolication.

// If we follow framework dependancies, the earliest reference to NSCopying is CoreFoundation, but NSCopying is really
// defined in Foundation.

// But it turns out that we can just use forward references for protocols.

@interface CDClassFrameworkVisitor : CDVisitor

// NSString (class name) -> NSString (framework name)
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *frameworkNamesByClassName;

// NSString (protocol name) -> NSString (framework name)
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *frameworkNamesByProtocolName;

@end
