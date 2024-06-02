// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDLCVersionMinimum.h>

#import <ClassDump/CDMachOFile.h>
#import <ClassDump/ClassDumpUtils.h>
@implementation CDLCVersionMinimum
{
    struct version_min_command _versionMinCommand;
}

- (instancetype)initWithDataCursor:(CDMachOFileDataCursor *)cursor;
{
    if ((self = [super initWithDataCursor:cursor])) {
        _versionMinCommand.cmd     = [cursor readInt32];
        _versionMinCommand.cmdsize = [cursor readInt32];
        _versionMinCommand.version = [cursor readInt32];
        _versionMinCommand.sdk     = [cursor readInt32];
    }

    return self;
}

#pragma mark -

- (uint32_t)cmd;
{
    return _versionMinCommand.cmd;
}

- (uint32_t)cmdsize;
{
    return _versionMinCommand.cmdsize;
}

- (NSString *)minimumVersionString;
{
    uint32_t x = (_versionMinCommand.version >> 16);
    uint32_t y = (_versionMinCommand.version >> 8) & 0xff;
    uint32_t z = _versionMinCommand.version & 0xff;

    return [NSString stringWithFormat:@"%u.%u.%u", x, y, z];
}

- (NSString *)SDKVersionString;
{
    uint32_t x = (_versionMinCommand.sdk >> 16);
    uint32_t y = (_versionMinCommand.sdk >> 8) & 0xff;
    uint32_t z = _versionMinCommand.sdk & 0xff;
    
    return [NSString stringWithFormat:@"%u.%u.%u", x, y, z];
}

- (void)appendToString:(NSMutableString *)resultString verbose:(BOOL)isVerbose;
{
    [super appendToString:resultString verbose:isVerbose];

    [resultString appendFormat:@"    Minimum version: %@\n", self.minimumVersionString];
    [resultString appendFormat:@"    SDK version: %@\n", self.SDKVersionString];
}

@end
