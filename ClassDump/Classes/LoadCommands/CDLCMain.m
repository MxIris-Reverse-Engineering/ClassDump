// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDLCMain.h>
#import <ClassDump/ClassDumpUtils.h>
@implementation CDLCMain
{
    struct entry_point_command _entryPointCommand;
}

- (instancetype)initWithDataCursor:(CDMachOFileDataCursor *)cursor;
{
    if ((self = [super initWithDataCursor:cursor])) {
        _entryPointCommand.cmd       = [cursor readInt32];
        _entryPointCommand.cmdsize   = [cursor readInt32];
        _entryPointCommand.entryoff  = [cursor readInt64];
        _entryPointCommand.stacksize = [cursor readInt64];
    }

    return self;
}

#pragma mark -

- (uint32_t)cmd;
{
    return _entryPointCommand.cmd;
}

- (uint32_t)cmdsize;
{
    return _entryPointCommand.cmdsize;
}

@end
