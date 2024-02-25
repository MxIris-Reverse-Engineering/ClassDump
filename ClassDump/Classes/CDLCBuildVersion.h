// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>
#import "CDLoadCommand.h"

@interface CDLCBuildVersion : CDLoadCommand

@property (nonatomic, readonly) NSString *buildVersionString;
@property (nonatomic, readonly) NSArray<NSNumber *> *toolStrings;
@end
