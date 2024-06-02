// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDOCMethod.h>

#import <ClassDump/CDClassDump.h>
#import <ClassDump/CDTypeFormatter.h>
#import <ClassDump/CDTypeParser.h>
#import <ClassDump/CDTypeController.h>
#import <ClassDump/ClassDumpUtils.h>
@implementation CDOCMethod
{
    NSString *_name;
    NSString *_typeString;
    NSUInteger _address;
    
    BOOL _hasParsedType;
    NSArray *_parsedMethodTypes;
}

- (instancetype)init;
{
    [NSException raise:@"RejectUnusedImplementation" format:@"-initWithName:typeString:imp: is the designated initializer"];
    return nil;
}

- (instancetype)initWithName:(NSString *)name typeString:(NSString *)typeString;
{
    return [self initWithName:name typeString:typeString address:0];
}

- (instancetype)initWithName:(NSString *)name typeString:(NSString *)typeString address:(NSUInteger)address;
{
    if ((self = [super init])) {
        _name = name;
        _typeString = typeString;
        _address = address;
        
        _hasParsedType = NO;
        _parsedMethodTypes = nil;
    }

    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone;
{
    return [[CDOCMethod alloc] initWithName:self.name typeString:self.typeString address:self.address];
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"[%@] name: %@, typeString: %@, address: 0x%016lx",
            NSStringFromClass([self class]), self.name, self.typeString, self.address];
}

#pragma mark -

- (NSArray *)parsedMethodTypes;
{
    if (_hasParsedType == NO) {
        NSError *error = nil;

        CDTypeParser *parser = [[CDTypeParser alloc] initWithString:self.typeString];
        _parsedMethodTypes = [parser parseMethodType:&error];
        if (_parsedMethodTypes == nil)
            DLog(@"Warning: Parsing method types failed, %@", self.name);
        _hasParsedType = YES;
    }

    return _parsedMethodTypes;
}

- (void)appendToString:(NSMutableString *)resultString typeController:(CDTypeController *)typeController;
{
    NSString *formattedString = [typeController.methodTypeFormatter formatMethodName:self.name typeString:self.typeString];
    if (formattedString != nil) {
        [resultString appendString:formattedString];
        [resultString appendString:@";"];
        if (typeController.shouldShowMethodAddresses && self.address != 0) {
            if (typeController.targetArchUses64BitABI)
                [resultString appendFormat:@"\t// IMP=0x%016lx", self.address];
            else
                [resultString appendFormat:@"\t// IMP=0x%08lx", self.address];
        }
    } else
        [resultString appendFormat:@"    // Error parsing type: %@, name: %@", self.typeString, self.name];
}

#pragma mark - Sorting

- (NSComparisonResult)ascendingCompareByName:(CDOCMethod *)other;
{
    return [self.name compare:other.name];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[CDOCMethod class]]) {
        CDOCMethod *otherMethod = object;
        return [self.name isEqualToString:otherMethod.name] && [self.typeString isEqualToString:otherMethod.typeString];
    } else {
        return [super isEqual:object];
    }
}

- (NSUInteger)hash {
    return NSUIntegerHashCombine(0, self.name, self.typeString, nil);
}

NSUInteger NSUIntegerHashCombine(NSUInteger seed, ...) {
    va_list args;
    va_start(args, seed);

    id obj;
    while ((obj = va_arg(args, id))) {
        // 可以根据需要选择不同的哈希算法
        // 这里使用位运算符 ^ 和素数来组合哈希值
        seed = seed ^ [obj hash] * 31;
    }

    va_end(args);
    return seed;
}



@end
