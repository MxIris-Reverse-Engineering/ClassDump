// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDOCModule.h>

#import <ClassDump/CDObjectiveC1Processor.h>
#import <ClassDump/CDOCSymtab.h>
#import <ClassDump/ClassDumpUtils.h>
@implementation CDOCModule
{
    uint32_t _version;
    NSString *_name;
    CDOCSymtab *_symtab;
}

- (instancetype)init;
{
    if ((self = [super init])) {
        _version = 0;
        _name = nil;
        _symtab = nil;
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"[%@] name: %@, version: %u, symtab: %@", NSStringFromClass([self class]), self.name, self.version, self.symtab];
}

#pragma mark -

- (NSString *)formattedString;
{
    return [NSString stringWithFormat:@"//\n// %@\n//\n", self.name];
}

@end
