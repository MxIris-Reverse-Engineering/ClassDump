// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDClassDump.h>

#import <ClassDump/CDFatArch.h>
#import <ClassDump/CDFatFile.h>
#import <ClassDump/CDLCDylib.h>
#import <ClassDump/CDMachOFile.h>
#import <ClassDump/CDObjectiveCProcessor.h>
#import <ClassDump/CDType.h>
#import <ClassDump/CDTypeFormatter.h>
#import <ClassDump/CDTypeParser.h>
#import <ClassDump/CDVisitor.h>
#import <ClassDump/CDLCSegment.h>
#import <ClassDump/CDTypeController.h>
#import <ClassDump/CDSearchPathState.h>
#import <ClassDump/CDClassDumpConfiguration.h>
#import <ClassDump/NSString-CDExtensions.h>
#import <ClassDump/ClassDumpUtils.h>
#import <ClassDump/CDClassDumpConfiguration.h>

NSString *CDErrorDomain_ClassDump = @"CDErrorDomain_ClassDump";

NSString *CDErrorKey_Exception    = @"CDErrorKey_Exception";

@interface CDClassDump ()
@end

#pragma mark -

@implementation CDClassDump {
    NSMutableArray<CDMachOFile *> *_machOFiles;
    NSMutableDictionary<NSString *, CDMachOFile *> *_machOFilesByName;
    NSMutableArray<CDObjectiveCProcessor *> *_objcProcessors;
}

@synthesize targetArch = _targetArch;

- (instancetype)init;
{
    if ((self = [super init])) {
        _configuration = [[CDClassDumpConfiguration alloc] init];
        _searchPathState = [[CDSearchPathState alloc] init];
//        _sdkRoot = nil;
        
        _machOFiles = [[NSMutableArray alloc] init];
        _machOFilesByName = [[NSMutableDictionary alloc] init];
        _objcProcessors = [[NSMutableArray alloc] init];
        
        _typeController = [[CDTypeController alloc] initWithConfiguration:_configuration];
        
        // These can be ppc, ppc7400, ppc64, i386, x86_64
        _targetArch.cputype = CPU_TYPE_ANY;
        _targetArch.cpusubtype = 0;
    }
    
    return self;
}

#pragma mark -

- (BOOL)containsObjectiveCData;
{
    for (CDObjectiveCProcessor *processor in self.objcProcessors) {
        if ([processor hasObjectiveCData])
            return YES;
    }
    
    return NO;
}

- (BOOL)hasEncryptedFiles;
{
    for (CDMachOFile *machOFile in self.machOFiles) {
        if ([machOFile isEncrypted]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)hasObjectiveCRuntimeInfo;
{
    return self.containsObjectiveCData || self.hasEncryptedFiles;
}

+ (BOOL)printFixupData {
    return [[[NSProcessInfo processInfo] arguments] containsObject:@"-F"];
}

- (BOOL)loadFile:(CDFile *)file error:(NSError *__autoreleasing *)error;
{
    CDLogInfo(@"loadFile: %@", file);
    //CDLog(@"targetArch: (%08x, %08x)", targetArch.cputype, targetArch.cpusubtype);
    CDMachOFile *machOFile = [file machOFileWithArch:_targetArch];
    //CDLog(@"machOFile: %@", machOFile);
    if (machOFile == nil) {
        if (error != NULL) {
            NSString *failureReason;
            NSString *targetArchName = CDNameForCPUType(_targetArch.cputype, _targetArch.cpusubtype);
            if ([file isKindOfClass:[CDFatFile class]] && [(CDFatFile *)file containsArchitecture:_targetArch]) {
                failureReason = [NSString stringWithFormat:@"Fat file doesn't contain a valid Mach-O file for the specified architecture (%@).  "
                                 "It probably means that class-dump was run on a static library, which is not supported.", targetArchName];
            } else {
                failureReason = [NSString stringWithFormat:@"File doesn't contain the specified architecture (%@).  Available architectures are %@.", targetArchName, file.architectureNameDescription];
            }
            NSDictionary *userInfo = @{ NSLocalizedFailureReasonErrorKey : failureReason };
            *error = [NSError errorWithDomain:CDErrorDomain_ClassDump code:0 userInfo:userInfo];
        }
        return NO;
    }
    
    // Set before processing recursively.  This was getting caught on CoreUI on 10.6
    assert([machOFile filename] != nil);
    [_machOFiles addObject:machOFile];
    _machOFilesByName[machOFile.filename] = machOFile;
    
    if (_configuration.shouldProcessRecursively) {
        @try {
            for (CDLoadCommand *loadCommand in [machOFile loadCommands]) {
                if ([loadCommand isKindOfClass:[CDLCDylib class]]) {
                    CDLCDylib *dylibCommand = (CDLCDylib *)loadCommand;
                    if ([dylibCommand cmd] == LC_LOAD_DYLIB) {
                        [self.searchPathState pushSearchPaths:[machOFile runPaths]];
                        {
                            NSString *loaderPathPrefix = @"@loader_path";
                            
                            NSString *path = [dylibCommand path];
                            if ([path hasPrefix:loaderPathPrefix]) {
                                NSString *loaderPath = [machOFile.filename stringByDeletingLastPathComponent];
                                path = [[path stringByReplacingOccurrencesOfString:loaderPathPrefix withString:loaderPath] stringByStandardizingPath];
                            }
                            [self machOFileWithName:path]; // Loads as a side effect
                        }
                        [self.searchPathState popSearchPaths];
                    }
                }
            }
        }
        @catch (NSException *exception) {
            CDLogError(@"Caught exception: %@", exception);
            if (error != NULL) {
                NSDictionary *userInfo = @{
                    NSLocalizedFailureReasonErrorKey : @"Caught exception",
                    CDErrorKey_Exception             : exception,
                };
                *error = [NSError errorWithDomain:CDErrorDomain_ClassDump code:0 userInfo:userInfo];
            }
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -

- (void)processObjectiveCData;
{
    
    for (CDMachOFile *machOFile in self.machOFiles) {
        CDObjectiveCProcessor *processor = [[[machOFile processorClass] alloc] initWithMachOFile:machOFile];
//        processor.shallow = _configuration.shallow;
        [processor processStoppingEarly:NO];
        [_objcProcessors addObject:processor];
    }
}

// This visits everything segment processors, classes, categories.  It skips over modules.  Need something to visit modules so we can generate separate headers.
- (void)recursivelyVisit:(CDVisitor *)visitor;
{
    [visitor willBeginVisiting];
    
    for (CDObjectiveCProcessor *processor in self.objcProcessors) {
        [processor recursivelyVisit:visitor];
    }
    
    [visitor didEndVisiting];
}

- (CDMachOFile *)machOFileWithName:(NSString *)name;
{
    NSString *adjustedName = nil;
    NSString *executablePathPrefix = @"@executable_path";
    NSString *rpathPrefix = @"@rpath";
    
    if ([name hasPrefix:executablePathPrefix]) {
        adjustedName = [name stringByReplacingOccurrencesOfString:executablePathPrefix withString:self.searchPathState.executablePath];
    } else if ([name hasPrefix:rpathPrefix]) {
        //CDLog(@"Searching for %@ through run paths: %@", name, [searchPathState searchPaths]);
        for (NSString *searchPath in [self.searchPathState searchPaths]) {
            NSString *str = [name stringByReplacingOccurrencesOfString:rpathPrefix withString:searchPath];
            //CDLog(@"trying %@", str);
            if ([[NSFileManager defaultManager] fileExistsAtPath:str]) {
                adjustedName = str;
                //CDLog(@"Found it!");
                break;
            }
        }
        if (adjustedName == nil) {
            adjustedName = name;
            //CDLog(@"Did not find it.");
        }
    } else if (_sdkRoot != nil) {
        adjustedName = [_sdkRoot stringByAppendingPathComponent:name];
    } else {
        adjustedName = name;
    }
    
    CDMachOFile *machOFile = _machOFilesByName[adjustedName];
    if (machOFile == nil) {
        CDFile *file = [CDFile fileWithContentsOfFile:adjustedName searchPathState:self.searchPathState];
        
        if (file == nil || [self loadFile:file error:NULL] == NO)
            CDLogWarning(@"Warning: Failed to load: %@", adjustedName);
        
        machOFile = _machOFilesByName[adjustedName];
        if (machOFile == nil) {
            CDLogWarning(@"Warning: Couldn't load MachOFile with ID: %@, adjustedID: %@", name, adjustedName);
        }
    }
    
    return machOFile;
}

- (void)appendHeaderToString:(NSMutableString *)resultString;
{
    // Since this changes each version, for regression testing it'll be better to be able to not show it.
    if (_configuration.shouldShowHeader == NO)
        return;
    
    [resultString appendString:@"//\n"];
    [resultString appendFormat:@"//     Generated by classdump-c %s.\n", CLASS_DUMP_VERSION];
    [resultString appendString:@"//\n"];
    [resultString appendString:@"//  Copyright (C) 1997-2019 Steve Nygard. Updated in 2022 by Kevin Bradley.\n"];
    [resultString appendString:@"//\n\n"];
    
    if (_sdkRoot != nil) {
        [resultString appendString:@"//\n"];
        [resultString appendFormat:@"// SDK Root: %@\n", _sdkRoot];
        [resultString appendString:@"//\n\n"];
    }
}

- (void)registerTypes;
{
    for (CDObjectiveCProcessor *processor in self.objcProcessors) {
        [processor registerTypesWithObject:self.typeController phase:0];
    }
    [self.typeController endPhase:0];
    
    [self.typeController workSomeMagic];
}

- (void)showHeader;
{
    if ([self.machOFiles count] > 0) {
        [[[self.machOFiles lastObject] headerString:YES] print];
    }
}

- (void)showLoadCommands;
{
    if ([self.machOFiles count] > 0) {
        [[[self.machOFiles lastObject] loadCommandString:YES] print];
    }
}

#pragma mark - Setters

- (void)setTargetArch:(CDArch)targetArch {
    @synchronized (self) {
        _targetArch = targetArch;
        _typeController.targetArchUses64BitABI = CDArchUses64BitABI(_targetArch);
    }
}

#pragma mark - Getters

- (CDArch)targetArch {
    @synchronized (self) {
        return _targetArch;
    }
}

#pragma mark -

- (void)dealloc {
    CDLog(@"CDClassDump is dealloc");
}

+ (CDClassDump *)classDumpContentsOfFile:(NSString *)path {
    NSString *executablePath = [path executablePathForFilename];
    if (executablePath){
        CDClassDump *classDump = [[CDClassDump alloc] init];
        classDump.searchPathState.executablePath = executablePath;
        CDFile *file = [CDFile fileWithContentsOfFile:executablePath searchPathState:classDump.searchPathState];
        if (file == nil) {
            NSFileManager *defaultManager = [NSFileManager defaultManager];
            
            if ([defaultManager fileExistsAtPath:executablePath]) {
                if ([defaultManager isReadableFileAtPath:executablePath]) {
                    CDLogError(@"Input file (%s) is neither a Mach-O file nor a fat archive.\n", [executablePath UTF8String]);
                } else {
                    CDLogError(@"Input file (%s) is not readable (check read permissions).\n", [executablePath UTF8String]);
                }
            } else {
                CDLogError(@"Input file (%s) does not exist.\n", [executablePath UTF8String]);
            }

            return nil;
        }
        
        //got this far file is not nil
        CDArch targetArch;
        if ([file bestMatchForLocalArch:&targetArch] == NO) {
            CDLogError(@"Error: Couldn't get local architecture\n");
            return nil;
        }
        //CDLog(@"No arch specified, best match for local arch is: (%08x, %08x)", targetArch.cputype, targetArch.cpusubtype);
        classDump.targetArch = targetArch;
        classDump.searchPathState.executablePath = [executablePath stringByDeletingLastPathComponent];
        NSError *error;
        if (![classDump loadFile:file error:&error]) {
            CDLogError(@"Error: %s\n", [[error localizedFailureReason] UTF8String]);
            return nil;
        }
        return classDump;
    }
    return nil;
}

+ (NSDictionary *)getFileEntitlements:(NSString *)file {
    CDClassDump *classDump = [self classDumpContentsOfFile:file];
    if (!classDump){
        CDLogError(@"couldnt create class dump instance for file: %@", file);
        return nil;
    }
    return [[[classDump machOFiles] firstObject] entitlementsDictionary];
}

+ (BOOL)performClassDumpOnFile:(NSString *)file toFolder:(NSString *)outputPath configuration:(nonnull CDClassDumpConfiguration *)configuration error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    @autoreleasepool {
        CDClassDump *classDump = [self classDumpContentsOfFile:file];
        if (!classDump){
            CDLog(@"couldnt create class dump instance for file: %@", file);
            
            *error = [NSError errorWithDomain:CDErrorDomain_ClassDump code:-1 userInfo:@{
                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"couldnt create class dump instance for file: %@", file]
            }];
            
            return NO;
        }
        [classDump->_configuration applyConfiguration:configuration];
//        classDump->_configuration = configuration;
//        classDump.shouldProcessRecursively = configuration.shouldProcessRecursively;
//        classDump.shouldSortClasses = configuration.shouldSortClasses;
//        classDump.shouldSortClassesByInheritance = configuration.shouldSortClassesByInheritance;
//        classDump.shouldSortMethods = configuration.shouldSortMethods;
//        classDump.shouldShowIvarOffsets = configuration.shouldShowIvarOffsets;
//        classDump.shouldShowMethodAddresses = configuration.shouldShowMethodAddresses;
//        classDump.shouldShowHeader = configuration.shouldShowHeader;
//        classDump.shouldStripOverrides = configuration.shouldStripOverrides;
//        classDump.shouldStripSynthesized = configuration.shouldStripSynthesized;
//        classDump.shouldStripCtor = configuration.shouldStripCtor;
//        classDump.shouldStripDtor = configuration.shouldStripDtor;
//        classDump.stopAfterPreProcessor = configuration.stopAfterPreProcessor;
//        classDump.shallow = configuration.shallow;
//        classDump.regularExpression = configuration.regularExpression;
//        classDump.sortedPropertyAttributeTypes = configuration.sortedPropertyAttributeTypes;
        
        [classDump processObjectiveCData];
        [classDump registerTypes];
        CDMultipleFileVisitor *multiFileVisitor = [[CDMultipleFileVisitor alloc] init]; // -H
        multiFileVisitor.classDump = classDump;
        multiFileVisitor.outputPath = outputPath;
        classDump.typeController.delegate = multiFileVisitor;
        [classDump recursivelyVisit:multiFileVisitor];
        return YES;
    }
}

@end
