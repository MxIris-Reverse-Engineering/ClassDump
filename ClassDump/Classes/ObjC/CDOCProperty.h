// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>

@class CDType;
@class CDOCPropertyAttribute;

@interface CDOCProperty : NSObject

- (instancetype)initWithName:(NSString *)name attributes:(NSString *)attributes isClass:(BOOL)isClass;

@property (readonly) NSString *name;
@property (readonly) NSString *attributeString;
@property (readonly) CDType *type;
@property (readonly) NSArray<NSString *> *attributes;
@property (readonly) NSArray<NSString *> *unknownAttributes;
@property (readonly) NSArray<CDOCPropertyAttribute *> *detailAttributes;
@property (readonly) NSString *ivar;
@property (readonly) NSString *attributeStringAfterType;

@property (readonly) NSString *defaultGetter;
@property (readonly) NSString *defaultSetter;

@property (readonly) NSString *customGetter;
@property (readonly) NSString *customSetter;

@property (readonly) NSString *getter;
@property (readonly) NSString *setter;

@property (readonly) BOOL isReadOnly;
@property (readonly) BOOL isDynamic;
@property (readonly) BOOL isClass;

- (NSComparisonResult)ascendingCompareByName:(CDOCProperty *)other;

@end
