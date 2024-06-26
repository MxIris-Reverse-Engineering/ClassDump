// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDFatArch.h>

#include <mach-o/fat.h>
#import <ClassDump/CDDataCursor.h>
#import <ClassDump/CDFatFile.h>
#import <ClassDump/CDMachOFile.h>
#import <ClassDump/ClassDumpUtils.h>
@implementation CDFatArch
{
    CDMachOFile *_machOFile; // Lazily create this.
    
    __weak CDMachOFile *_machOFileFromInit;
}

- (instancetype)initWithMachOFile:(CDMachOFile *)machOFile;
{
    if ((self = [super init])) {
        _machOFileFromInit = machOFile;
        NSParameterAssert([machOFile.data length] < 0x100000000);
        
        _cputype    = machOFile.cputype;
        _cpusubtype = machOFile.cpusubtype;
        _offset     = 0; // Would be filled in when this is written to disk
        _size       = (uint32_t)[machOFile.data length];
        _align      = 12; // 2**12 = 4096 (0x1000)
    }
    
    return self;
}

- (instancetype)initWithDataCursor:(CDDataCursor *)cursor;
{
    if ((self = [super init])) {
        _cputype    = [cursor readBigInt32];
        _cpusubtype = [cursor readBigInt32];
        _offset     = [cursor readBigInt32];
        _size       = [cursor readBigInt32];
        _align      = [cursor readBigInt32];
        
        //CDLog(@"self: %@", self);
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"64 bit ABI? %d, cputype: 0x%08x, cpusubtype: 0x%08x, offset: 0x%08x (%8u), size: 0x%08x (%8u), align: 2^%u (%x), arch name: %@",
            self.uses64BitABI, self.cputype, self.cpusubtype, self.offset, self.offset, self.size, self.size,
            self.align, 1 << self.align, self.archName];
}

#pragma mark -

- (cpu_type_t)maskedCPUType;
{
    return self.cputype & ~CPU_ARCH_MASK;
}

- (cpu_subtype_t)maskedCPUSubtype;
{
    return self.cpusubtype & ~CPU_SUBTYPE_MASK;
}

- (BOOL)uses64BitABI;
{
    return CDArchUses64BitABI(self.arch);
}

- (BOOL)uses64BitLibraries;
{
    return CDArchUses64BitLibraries(self.arch);
}

- (CDArch)arch;
{
    CDArch arch = { self.cputype, self.cpusubtype };

    return arch;
}

// Must not return nil.
- (NSString *)archName;
{
    return CDNameForCPUType(self.cputype, self.cpusubtype);
}

- (CDMachOFile *)machOFile;
{
    if (_machOFileFromInit) {
        return _machOFileFromInit;
    }
    
    if (_machOFile == nil) {
        NSData *data = [NSData dataWithBytesNoCopy:((uint8_t *)[self.fatFile.data bytes] + self.offset) length:self.size freeWhenDone:NO];
        _machOFile = [[CDMachOFile alloc] initWithData:data filename:self.fatFile.filename searchPathState:self.fatFile.searchPathState];
    }

    return _machOFile;
}

@end
