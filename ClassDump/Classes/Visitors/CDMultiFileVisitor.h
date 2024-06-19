// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>
#import <ClassDump/CDTextClassDumpVisitor.h>
#import <ClassDump/CDTypeController.h> // For CDTypeControllerDelegate protocol

// This generates separate files for each class.  Files are created in the 'outputPath' directory.

@protocol CDProtocolFileNameFormatter <NSObject>

- (NSString *)stringForProtocolName:(NSString *)protocolName;

@end

@protocol CDCategoryFileNameFormatter <NSObject>

- (NSString *)stringForClassName:(NSString *)className categoryName:(NSString *)categoryName;

@end


@interface CDMultiFileVisitor : CDTextClassDumpVisitor <CDTypeControllerDelegate>

@property BOOL shouldAppendHeader;

@property NSString *preferredStructureFileName;

@property BOOL shouldGenerateEmptyImplementationFile;

@property (weak) id<CDProtocolFileNameFormatter> protocolFileNameFormatter;

@property (weak) id<CDCategoryFileNameFormatter> categoryFileNameFormatter;

@property (strong) NSString *outputPath;

@end


