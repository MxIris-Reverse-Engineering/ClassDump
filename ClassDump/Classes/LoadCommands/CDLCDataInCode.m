// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDLCDataInCode.h>

#import <ClassDump/CDMachOFile.h>
#import <ClassDump/ClassDumpUtils.h>
@implementation CDLCDataInCode
{
}

- (instancetype)initWithDataCursor:(CDMachOFileDataCursor *)cursor;
{
    if ((self = [super initWithDataCursor:cursor])) {
    }

    return self;
}

#pragma mark -

@end
