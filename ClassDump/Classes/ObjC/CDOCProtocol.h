// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>

@class CDTypeController;
@class CDVisitor, CDVisitorPropertyState;
@class CDOCMethod, CDOCProperty;

@interface CDOCProtocol : NSObject

@property (strong) NSString *name;

@property (readonly) NSArray<CDOCProtocol *> *protocols;
- (void)addProtocol:(CDOCProtocol *)protocol;
- (void)removeProtocol:(CDOCProtocol *)protocol;

@property (readonly) NSArray<NSString *> *protocolNames;
@property (readonly) NSString *protocolsString;

@property (readonly) NSOrderedSet<CDOCMethod *> *classMethods; // TODO: NSArray vs. NSMutableArray
- (void)addClassMethod:(CDOCMethod *)method;
- (BOOL)containsClassMethod:(CDOCMethod *)method;

@property (readonly) NSOrderedSet<CDOCMethod *> *instanceMethods;
- (void)addInstanceMethod:(CDOCMethod *)method;
- (BOOL)containsInstanceMethod:(CDOCMethod *)method;

@property (readonly) NSOrderedSet<CDOCMethod *> *optionalClassMethods;
- (void)addOptionalClassMethod:(CDOCMethod *)method;
- (BOOL)containsOptionalClassMethod:(CDOCMethod *)method;

@property (readonly) NSOrderedSet<CDOCMethod *> *optionalInstanceMethods;
- (void)addOptionalInstanceMethod:(CDOCMethod *)method;
- (BOOL)containsOptionalInstanceMethod:(CDOCMethod *)method;

@property (readonly) NSArray<CDOCProperty *> *properties;
- (void)addProperty:(CDOCProperty *)property;

@property (readonly) BOOL hasMethods;

- (void)registerTypesWithObject:(CDTypeController *)typeController phase:(NSUInteger)phase;
//- (void)registerTypesFromMethods:(NSOrderedSet<CDOCMethod *> *)methods withObject:(CDTypeController *)typeController phase:(NSUInteger)phase;

- (NSComparisonResult)ascendingCompareByName:(CDOCProtocol *)other;

- (NSString *)methodSearchContext;
- (void)recursivelyVisit:(CDVisitor *)visitor;

- (void)visitMethods:(CDVisitor *)visitor propertyState:(CDVisitorPropertyState *)propertyState;

- (void)mergeMethodsFromProtocol:(CDOCProtocol *)other;
- (void)mergePropertiesFromProtocol:(CDOCProtocol *)other;

@end
