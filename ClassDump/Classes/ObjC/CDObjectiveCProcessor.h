// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>

@class CDMachOFile, CDSection, CDTypeController, CDVisitor, CDOCClass, CDOCCategory, CDProtocolUniquer;

@interface CDObjectiveCProcessor : NSObject

@property (weak, readonly) CDMachOFile *machOFile;
@property (readonly) BOOL hasObjectiveCData;
@property (assign) BOOL shallow;

@property (readonly) CDSection *objcImageInfoSection;
@property (readonly) NSString *garbageCollectionStatus;
@property (readonly) CDProtocolUniquer *protocolUniquer;

@property BOOL shouldStripOverrideMethods;

- (instancetype)initWithMachOFile:(CDMachOFile *)machOFile;

- (void)addClass:(CDOCClass *)aClass withAddress:(uint64_t)address;
- (void)addClassesFromArray:(NSArray<CDOCClass *> *)array;
- (void)addCategoriesFromArray:(NSArray<CDOCCategory *> *)array;
- (void)addCategory:(CDOCCategory *)category;

- (void)process;
- (void)processStoppingEarly:(BOOL)stopEarly;
- (void)loadProtocols;
- (void)loadClasses;
- (void)loadCategories;

- (void)registerTypesWithObject:(CDTypeController *)typeController phase:(NSUInteger)phase;
- (void)recursivelyVisit:(CDVisitor *)visitor;

- (CDOCClass *)classWithAddress:(uint64_t)address;
- (NSArray<NSNumber *> *)protocolAddressListAtAddress:(uint64_t)address;


@end
