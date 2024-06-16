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

#import <ClassDump/NSString-CDExtensions.h>
#import <ClassDump/ClassDumpUtils.h>

NSString *CDErrorDomain_ClassDump = @"CDErrorDomain_ClassDump";

NSString *CDErrorKey_Exception    = @"CDErrorKey_Exception";

@interface CDClassDump ()
@end

#pragma mark -

@implementation CDClassDump
{
    NSMutableArray *_machOFiles;
    NSMutableDictionary *_machOFilesByName;
    NSMutableArray *_objcProcessors;
}

- (instancetype)init;
{
    if ((self = [super init])) {
        _searchPathState = [[CDSearchPathState alloc] init];
        _sdkRoot = nil;
        
        _machOFiles = [[NSMutableArray alloc] init];
        _machOFilesByName = [[NSMutableDictionary alloc] init];
        _objcProcessors = [[NSMutableArray alloc] init];
        
        _typeController = [[CDTypeController alloc] initWithClassDump:self];
        
        // These can be ppc, ppc7400, ppc64, i386, x86_64
        _targetArch.cputype = CPU_TYPE_ANY;
        _targetArch.cpusubtype = 0;
        
        _shouldShowHeader = NO;
    }
    
    return self;
}

#pragma mark - Regular expression handling

- (BOOL)shouldShowName:(NSString *)name;
{
    if (self.regularExpression != nil) {
        NSTextCheckingResult *firstMatch = [self.regularExpression firstMatchInString:name options:(NSMatchingOptions)0 range:NSMakeRange(0, [name length])];
        return firstMatch != nil;
    }
    
    return YES;
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
    
    if ([self shouldProcessRecursively]) {
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
    CDLogInfo_CMD;
    for (CDMachOFile *machOFile in self.machOFiles) {
        CDObjectiveCProcessor *processor = [[[machOFile processorClass] alloc] initWithMachOFile:machOFile];
        processor.shallow = self.shallow;
        [processor processStoppingEarly:self.stopAfterPreProcessor];
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
    } else if (self.sdkRoot != nil) {
        adjustedName = [self.sdkRoot stringByAppendingPathComponent:name];
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
    if (self.shouldShowHeader == NO)
        return;
    
    [resultString appendString:@"//\n"];
    [resultString appendFormat:@"//     Generated by classdump-c %s.\n", CLASS_DUMP_VERSION];
    [resultString appendString:@"//\n"];
    [resultString appendString:@"//  Copyright (C) 1997-2019 Steve Nygard. Updated in 2022 by Kevin Bradley.\n"];
    [resultString appendString:@"//\n\n"];
    
    if (self.sdkRoot != nil) {
        [resultString appendString:@"//\n"];
        [resultString appendFormat:@"// SDK Root: %@\n", self.sdkRoot];
        [resultString appendString:@"//\n\n"];
    }
}

- (void)registerTypes;
{
    CDLogInfo_CMD;
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

- (void)setSortedPropertyAttributeTypes:(NSArray<CDOCPropertyAttributeType> *)sortedPropertyAttributeTypes {
    _sortedPropertyAttributeTypes = sortedPropertyAttributeTypes;
    if (sortedPropertyAttributeTypes) {
        BOOL containsAllPropertyAttributeTypes = [sortedPropertyAttributeTypes containsObject:CDOCPropertyAttributeTypeClass] && 
                                                 [sortedPropertyAttributeTypes containsObject:CDOCPropertyAttributeTypeGetter] &&
                                                 [sortedPropertyAttributeTypes containsObject:CDOCPropertyAttributeTypeSetter] &&
                                                 [sortedPropertyAttributeTypes containsObject:CDOCPropertyAttributeTypeReadwrite] &&
                                                 [sortedPropertyAttributeTypes containsObject:CDOCPropertyAttributeTypeReference] &&
                                                 [sortedPropertyAttributeTypes containsObject:CDOCPropertyAttributeTypeThreadSafe];
        NSAssert(containsAllPropertyAttributeTypes, @"All attribute types must be included.");
        NSMutableDictionary<CDOCPropertyAttributeType, NSNumber *> *propertyAttributeTypeWeights = [NSMutableDictionary dictionary];
        propertyAttributeTypeWeights[CDOCPropertyAttributeTypeClass] = @([sortedPropertyAttributeTypes indexOfObject:CDOCPropertyAttributeTypeClass]);
        propertyAttributeTypeWeights[CDOCPropertyAttributeTypeSetter] = @([sortedPropertyAttributeTypes indexOfObject:CDOCPropertyAttributeTypeSetter]);
        propertyAttributeTypeWeights[CDOCPropertyAttributeTypeGetter] = @([sortedPropertyAttributeTypes indexOfObject:CDOCPropertyAttributeTypeGetter]);
        propertyAttributeTypeWeights[CDOCPropertyAttributeTypeReadwrite] = @([sortedPropertyAttributeTypes indexOfObject:CDOCPropertyAttributeTypeReadwrite]);
        propertyAttributeTypeWeights[CDOCPropertyAttributeTypeReference] = @([sortedPropertyAttributeTypes indexOfObject:CDOCPropertyAttributeTypeReference]);
        propertyAttributeTypeWeights[CDOCPropertyAttributeTypeThreadSafe] = @([sortedPropertyAttributeTypes indexOfObject:CDOCPropertyAttributeTypeThreadSafe]);
        _propertyAttributeTypeWeights = propertyAttributeTypeWeights;
    }
}

- (void)dealloc {
    CDLog(@"CDClassDump is dealloc");
}

+ (CDClassDump *)classDumpInstanceFromFile:(NSString *)file {
    NSString *executablePath = [file executablePathForFilename];
    if (executablePath){
        CDClassDump *classDump = [[CDClassDump alloc] init];
        classDump.searchPathState.executablePath = executablePath;
        CDFile *file = [CDFile fileWithContentsOfFile:executablePath searchPathState:classDump.searchPathState];
        if (file == nil) {
            NSFileManager *defaultManager = [NSFileManager defaultManager];
            
            if ([defaultManager fileExistsAtPath:executablePath]) {
                if ([defaultManager isReadableFileAtPath:executablePath]) {
                    fprintf(stderr, "class-dump: Input file (%s) is neither a Mach-O file nor a fat archive.\n", [executablePath UTF8String]);
                } else {
                    fprintf(stderr, "class-dump: Input file (%s) is not readable (check read permissions).\n", [executablePath UTF8String]);
                }
            } else {
                fprintf(stderr, "class-dump: Input file (%s) does not exist.\n", [executablePath UTF8String]);
            }

            return nil;
        }
        
        //got this far file is not nil
        CDArch targetArch;
        if ([file bestMatchForLocalArch:&targetArch] == NO) {
            fprintf(stderr, "Error: Couldn't get local architecture\n");
            return nil;
        }
        //CDLog(@"No arch specified, best match for local arch is: (%08x, %08x)", targetArch.cputype, targetArch.cpusubtype);
        classDump.targetArch = targetArch;
        classDump.searchPathState.executablePath = [executablePath stringByDeletingLastPathComponent];
        NSError *error;
        if (![classDump loadFile:file error:&error]) {
            fprintf(stderr, "Error: %s\n", [[error localizedFailureReason] UTF8String]);
            return nil;
        }
        return classDump;
    }
    return nil;
}

+ (NSDictionary *)getFileEntitlements:(NSString *)file {
    CDClassDump *classDump = [self classDumpInstanceFromFile:file];
    if (!classDump){
        CDLog(@"couldnt create class dump instance for file: %@", file);
        return nil;
    }
    return [[[classDump machOFiles] firstObject] entitlementsDictionary];
}

+ (BOOL)performClassDumpOnFile:(NSString *)file toFolder:(NSString *)outputPath error:(NSError **)error {
    return [self performClassDumpOnFile:file withEntitlements:YES toFolder:outputPath error:error];
}

+ (BOOL)performClassDumpOnFile:(NSString *)file withEntitlements:(BOOL)dumpEnt toFolder:(NSString *)outputPath error:(NSError **)error {
    @autoreleasepool {
        CDClassDump *classDump = [self classDumpInstanceFromFile:file];
        if (!classDump){
            CDLog(@"couldnt create class dump instance for file: %@", file);
            
            *error = [NSError errorWithDomain:CDErrorDomain_ClassDump code:-1 userInfo:@{
                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"couldnt create class dump instance for file: %@", file]
            }];
            
            return NO;
        }
        classDump.shouldShowIvarOffsets = YES; // -a
        classDump.shouldShowMethodAddresses = NO; // -A
        [classDump processObjectiveCData];
        [classDump registerTypes];
        CDMultiFileVisitor *multiFileVisitor = [[CDMultiFileVisitor alloc] init]; // -H
        multiFileVisitor.classDump = classDump;
        multiFileVisitor.outputPath = outputPath;
        classDump.typeController.delegate = multiFileVisitor;
        [classDump recursivelyVisit:multiFileVisitor];
        return YES;
    }
}

@end
