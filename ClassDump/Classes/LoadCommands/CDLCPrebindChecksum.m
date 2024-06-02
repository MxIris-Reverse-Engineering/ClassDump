// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDLCPrebindChecksum.h>
#import <ClassDump/ClassDumpUtils.h>
@implementation CDLCPrebindChecksum
{
    struct prebind_cksum_command _prebindChecksumCommand;
}

- (instancetype)initWithDataCursor:(CDMachOFileDataCursor *)cursor;
{
    if ((self = [super initWithDataCursor:cursor])) {
        _prebindChecksumCommand.cmd     = [cursor readInt32];
        _prebindChecksumCommand.cmdsize = [cursor readInt32];
        _prebindChecksumCommand.cksum   = [cursor readInt32];
    }

    return self;
}

#pragma mark -

- (uint32_t)cmd;
{
    return _prebindChecksumCommand.cmd;
}

- (uint32_t)cmdsize;
{
    return _prebindChecksumCommand.cmdsize;
}

- (uint32_t)cksum;
{
    return _prebindChecksumCommand.cksum;
}

@end
