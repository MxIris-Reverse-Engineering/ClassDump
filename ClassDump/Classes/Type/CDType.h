// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>

@class CDTypeController, CDTypeFormatter, CDTypeName;

@interface CDType : NSObject <NSCopying>

@property (strong) NSString *variableName;

@property (readonly) int primitiveType;
@property (readonly) BOOL isIDType;
@property (readonly) BOOL isNamedObject;
@property (readonly) BOOL isTemplateType;

@property (readonly) CDType *subtype;
@property (readonly) CDTypeName *typeName;

@property (readonly) NSArray *members;
@property (readonly) NSArray *types;

@property (readonly) int typeIgnoringModifiers;
@property (readonly) NSUInteger structureDepth;
@property (readonly) NSArray *protocols;
@property (readonly) NSString *bitfieldSize;
@property (readonly) NSString *arraySize;

@property (readonly) NSString *typeString;
@property (readonly) NSString *bareTypeString;
@property (readonly) NSString *reallyBareTypeString;
@property (readonly) NSString *keyTypeString;
@property (readonly) NSArray *memberVariableNames;

- (instancetype)initSimpleType:(int)type;
- (instancetype)initIDType:(CDTypeName *)name;
- (instancetype)initIDType:(CDTypeName *)name withProtocols:(NSArray *)protocols;
- (instancetype)initIDTypeWithProtocols:(NSArray *)protocols;
- (instancetype)initStructType:(CDTypeName *)name members:(NSArray *)members;
- (instancetype)initUnionType:(CDTypeName *)name members:(NSArray *)members;
- (instancetype)initBitfieldType:(NSString *)bitfieldSize;
- (instancetype)initArrayType:(CDType *)type count:(NSString *)count;
- (instancetype)initPointerType:(CDType *)type;
- (instancetype)initFunctionPointerType;
- (instancetype)initBlockTypeWithTypes:(NSArray *)types;
- (instancetype)initModifier:(int)modifier type:(CDType *)type;

- (BOOL)canMergeWithType:(CDType *)otherType;
- (void)mergeWithType:(CDType *)otherType;
- (void)generateMemberNames;
- (void)phase0RecursivelyFixStructureNames;

@end
