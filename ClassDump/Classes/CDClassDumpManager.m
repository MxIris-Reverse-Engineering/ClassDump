//
//  classdump.m
//  classdump
//
//  Created by Kevin Bradley on 6/21/22.
//
#import <stdio.h>
#import <unistd.h>
#import <string.h>
#import <pthread.h>
#import <unistd.h>
#import <getopt.h>
#import <stdlib.h>
#import <mach-o/arch.h>
#import "CDExtensions.h"
#import "CDFindMethodVisitor.h"
#import "CDClassDumpVisitor.h"
#import "CDMultiFileVisitor.h"
#import "CDFile.h"
#import "CDMachOFile.h"
#import "CDFatFile.h"
#import "CDFatArch.h"
#import "CDSearchPathState.h"
#import "CDClassDumpManager.h"
#import "CDClassDump.h"
#import "ClassDumpUtils.h"

@implementation CDClassDumpManager

+ (id)sharedManager {
    
    static dispatch_once_t onceToken;
    static CDClassDumpManager *shared;
    if (!shared){
        dispatch_once(&onceToken, ^{
            shared = [CDClassDumpManager new];
        });
    }
    return shared;
}

- (CDClassDump *)classDumpInstanceFromFile:(NSString *)file {
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
        //DLog(@"No arch specified, best match for local arch is: (%08x, %08x)", targetArch.cputype, targetArch.cpusubtype);
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

- (NSDictionary *)getFileEntitlements:(NSString *)file {
    CDClassDump *classDump = [self classDumpInstanceFromFile:file];
    if (!classDump){
        DLog(@"couldnt create class dump instance for file: %@", file);
        return nil;
    }
    return [[[classDump machOFiles] firstObject] entitlementsDictionary];
}

- (BOOL)performClassDumpOnFile:(NSString *)file toFolder:(NSString *)outputPath error:(NSError **)error {
    return [self performClassDumpOnFile:file withEntitlements:YES toFolder:outputPath error:error];
}

- (BOOL)performClassDumpOnFile:(NSString *)file withEntitlements:(BOOL)dumpEnt toFolder:(NSString *)outputPath error:(NSError **)error {
    CDClassDump *classDump = [self classDumpInstanceFromFile:file];
    if (!classDump){
        DLog(@"couldnt create class dump instance for file: %@", file);
        
        *error = [NSError errorWithDomain:NSErrorDomain_ClassDump code:-1 userInfo:@{
            NSLocalizedDescriptionKey: [NSString stringWithFormat:@"couldnt create class dump instance for file: %@", file]
        }];
        
        return NO;
    }
    classDump.shouldShowIvarOffsets = true; // -a
    classDump.shouldShowMethodAddresses = false; // -A
    classDump.verbose = self.verbose;
    [classDump processObjectiveCData];
    [classDump registerTypes];
    CDMultiFileVisitor *multiFileVisitor = [[CDMultiFileVisitor alloc] init]; // -H
    multiFileVisitor.classDump = classDump;
    multiFileVisitor.outputPath = outputPath;
    classDump.typeController.delegate = multiFileVisitor;
    [classDump recursivelyVisit:multiFileVisitor];
    return YES;
}

- (NSInteger)oldperformClassDumpOnFile:(NSString *)file toFolder:(NSString *)outputPath {
    
    CDClassDump *classDump = [[CDClassDump alloc] init];
    classDump.shouldShowIvarOffsets = true; // -a
    classDump.shouldShowMethodAddresses = true; // -A
    //classDump.shouldSortClassesByInheritance = true; // -I
    NSString *executablePath = [file executablePathForFilename];
    if (executablePath){
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

            return 1;
        }
        
        //got this far file is not nil
        CDArch targetArch;
        if ([file bestMatchForLocalArch:&targetArch] == NO) {
            fprintf(stderr, "Error: Couldn't get local architecture\n");
            return 1;
        }
        //DLog(@"No arch specified, best match for local arch is: (%08x, %08x)", targetArch.cputype, targetArch.cpusubtype);
        classDump.targetArch = targetArch;
        classDump.searchPathState.executablePath = [executablePath stringByDeletingLastPathComponent];
        
        NSError *error;
        if (![classDump loadFile:file error:&error]) {
            fprintf(stderr, "Error: %s\n", [[error localizedFailureReason] UTF8String]);
            return 1;
        } else {
            [classDump processObjectiveCData];
            [classDump registerTypes];
            CDMultiFileVisitor *multiFileVisitor = [[CDMultiFileVisitor alloc] init]; // -H
            multiFileVisitor.classDump = classDump;
            classDump.typeController.delegate = multiFileVisitor;
            multiFileVisitor.outputPath = outputPath;
            [classDump recursivelyVisit:multiFileVisitor];
        }
    } else {
        fprintf(stderr, "no exe path found for: %s\n", [file UTF8String]);
        return -1;
    }
    return 0;
}

@end
