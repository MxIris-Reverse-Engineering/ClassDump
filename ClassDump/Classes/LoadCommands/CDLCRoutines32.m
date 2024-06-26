// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDLCRoutines32.h>
#import <ClassDump/ClassDumpUtils.h>
@implementation CDLCRoutines32
{
    struct routines_command _routinesCommand;
}

- (instancetype)initWithDataCursor:(CDMachOFileDataCursor *)cursor;
{
    if ((self = [super initWithDataCursor:cursor])) {
        _routinesCommand.cmd     = [cursor readInt32];
        _routinesCommand.cmdsize = [cursor readInt32];
        
        _routinesCommand.init_address = [cursor readInt32];
        _routinesCommand.init_module  = [cursor readInt32];
        _routinesCommand.reserved1    = [cursor readInt32];
        _routinesCommand.reserved2    = [cursor readInt32];
        _routinesCommand.reserved3    = [cursor readInt32];
        _routinesCommand.reserved4    = [cursor readInt32];
        _routinesCommand.reserved5    = [cursor readInt32];
        _routinesCommand.reserved6    = [cursor readInt32];
    }

    return self;
}

#pragma mark -

- (uint32_t)cmd;
{
    return _routinesCommand.cmd;
}

- (uint32_t)cmdsize;
{
    return _routinesCommand.cmdsize;
}

@end
