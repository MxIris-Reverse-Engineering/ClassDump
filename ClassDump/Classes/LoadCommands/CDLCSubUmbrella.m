// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDLCSubUmbrella.h>
#import <ClassDump/ClassDumpUtils.h>
@implementation CDLCSubUmbrella
{
    struct sub_umbrella_command _command;
    NSString *_name;
}

- (instancetype)initWithDataCursor:(CDMachOFileDataCursor *)cursor;
{
    if ((self = [super initWithDataCursor:cursor])) {
        _command.cmd     = [cursor readInt32];
        _command.cmdsize = [cursor readInt32];
        
        NSUInteger length = _command.cmdsize - sizeof(_command);
        //CDLog(@"expected length: %u", length);
        
        _name = [cursor readStringOfLength:length encoding:NSASCIIStringEncoding];
        //CDLog(@"name: %@", _name);
    }

    return self;
}

#pragma mark -

- (uint32_t)cmd;
{
    return _command.cmd;
}

- (uint32_t)cmdsize;
{
    return _command.cmdsize;
}

@end
