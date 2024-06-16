//
//  ClassDumpTests.m
//  ClassDumpTests
//
//  Created by JH on 2024/6/1.
//

#import <XCTest/XCTest.h>
#import <ClassDump/ClassDump.h>
#import <AppKit/AppKit.h>


@interface NSString (Utils)
- (NSString *)executablePathForFilename;
@end

@implementation NSString (Utils)

- (NSString *)executablePathForFilename;
{
    NSString *path;

    // I give up, all the methods dealing with paths seem to resolve symlinks with a vengence.
    NSBundle *bundle = [NSBundle bundleWithPath:self];
    if (bundle != nil) {
        if ([bundle executablePath] == nil)
            return nil;

        path = [[[bundle executablePath] stringByResolvingSymlinksInPath] stringByStandardizingPath];
    } else {
        path = [[self stringByResolvingSymlinksInPath] stringByStandardizingPath];
    }

    return path;
}

@end

@interface ClassDumpTests : XCTestCase

@end



@implementation ClassDumpTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    NSURL *currentSourceFileURL = [NSURL fileURLWithPath:@__FILE__];
    NSURL *dumpFromURL = [[currentSourceFileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"ClassDumpTestsSupport.framework/Versions/A/ClassDumpTestsSupport"];
    NSURL *dumpToURL = [[currentSourceFileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"Dump"];
    CDClassDump *classDump = [self classDumpInstanceFromFile:dumpFromURL.path];
    if (!classDump){
        XCTAssert(NO, @"couldnt create class dump instance for file: %@", dumpFromURL.path);
        return;
    }
    classDump.shouldShowIvarOffsets = YES; // -a
    classDump.shouldShowMethodAddresses = NO; // -A
    classDump.shouldStripOverrides = YES;
    classDump.shouldStripSynthesized = YES;
    classDump.shouldStripCtor = YES;
    classDump.shouldStripDtor = YES;
    classDump.verbose = YES;
    classDump.sortedPropertyAttributeTypes = @[
        CDOCPropertyAttributeTypeThreadSafe,
        CDOCPropertyAttributeTypeReference,
        CDOCPropertyAttributeTypeReadwrite,
        CDOCPropertyAttributeTypeClass,
        CDOCPropertyAttributeTypeGetter,
        CDOCPropertyAttributeTypeSetter,
    ];
    [classDump processObjectiveCData];
    [classDump registerTypes];
    CDMultiFileVisitor *multiFileVisitor = [[CDMultiFileVisitor alloc] init]; // -H
    multiFileVisitor.classDump = classDump;
    multiFileVisitor.outputPath = dumpToURL.path;
    classDump.typeController.delegate = multiFileVisitor;
    [classDump recursivelyVisit:multiFileVisitor];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[dumpToURL]];
}

- (void)testDumpFramework {
    @autoreleasepool {
        NSURL *dumpFromURL = [NSURL fileURLWithPath:@"/Volumes/FrameworkLab/Numbers/Frameworks/TSTables.framework/Versions/A/TSTables"];
        NSURL *dumpToURL = [NSURL fileURLWithPath:@"/Volumes/FrameworkLab/Numbers/FrameworksDumpHeaders/TSTables"];
        CDClassDump *classDump = [self classDumpInstanceFromFile:dumpFromURL.path];
        if (!classDump){
            XCTAssert(NO, @"couldnt create class dump instance for file: %@", dumpFromURL.path);
            return;
        }
        classDump.shouldShowIvarOffsets = YES; // -a
        classDump.shouldShowMethodAddresses = NO; // -A
        classDump.shouldStripOverrides = YES;
        classDump.shouldStripSynthesized = YES;
        classDump.verbose = YES;
        [classDump processObjectiveCData];
        [classDump registerTypes];
        CDMultiFileVisitor *multiFileVisitor = [[CDMultiFileVisitor alloc] init]; // -H
        multiFileVisitor.classDump = classDump;
        multiFileVisitor.outputPath = dumpToURL.path;
        classDump.typeController.delegate = multiFileVisitor;
        [classDump recursivelyVisit:multiFileVisitor];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[dumpToURL]];
    }
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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}



@end
