// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDTypeFormatter.h>

#import <ClassDump/CDMethodType.h>
#import <ClassDump/CDType.h>
#import <ClassDump/CDTypeLexer.h>
#import <ClassDump/CDTypeParser.h>
#import <ClassDump/CDTypeController.h>
#import <ClassDump/NSString-CDExtensions.h>
#import <ClassDump/NSScanner-CDExtensions.h>
#import <ClassDump/ClassDumpUtils.h>
#import <ClassDump/CDClassDumpConfiguration.h>
#import <ClassDump/CDTypeName.h>


@interface CDTypeFormatter ()
@end

#pragma mark -

@implementation CDTypeFormatter

- (instancetype)initWithConfiguration:(CDClassDumpConfiguration *)configuration
{
    if ((self = [super init])) {
        _baseLevel = 0;
        _shouldExpand = NO;
        _shouldAutoExpand = NO;
        _configuration = configuration;
    }

    return self;
}
#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@:%p> baseLevel: %lu, shouldExpand: %u, shouldAutoExpand: %u, shouldShowLexing: %u",
            NSStringFromClass([self class]), self,
            self.baseLevel, self.shouldExpand, self.shouldAutoExpand, self.shouldShowLexing];
}

#pragma mark -

- (NSString *)_specialCaseVariable:(NSString *)name type:(NSString *)type;
{
    if ([type isEqual:@"c"]) {
        if (name == nil)
            return @"BOOL";
        else
            return [NSString stringWithFormat:@"BOOL %@", name];
#if 0
    } else if ([type isEqual:@"b1"]) {
        if (name == nil)
            return @"BOOL :1";
        else
            return [NSString stringWithFormat:@"BOOL %@:1", name];
#endif
    }

    return nil;
}

- (NSString *)_specialCaseVariable:(NSString *)name parsedType:(CDType *)type;
{
    if (type.primitiveType == 'c') {
        if (name == nil)
            return @"BOOL";
        else
            return [NSString stringWithFormat:@"BOOL %@", name];
    }

    return nil;
}

- (NSString *)formatVariable:(NSString *)name type:(CDType *)type;
{
    NSMutableString *resultString = [NSMutableString string];

    NSString *specialCase = [self _specialCaseVariable:name parsedType:type];
    [resultString appendSpacesIndentedToLevel:self.baseLevel spacesPerLevel:4];
    if (specialCase != nil) {
        [resultString appendString:specialCase];
    } else {
        // TODO: (2009-08-26) Ideally, just formatting a type shouldn't change it.  These changes should be done before, but this is handy.
        type.variableName = name;
        [type phase0RecursivelyFixStructureNames]; // Nuke the $_ names
//        [type phase3MergeWithTypeController:self.typeController];
        [self.delegate phase3MergeWithType:type];
        [resultString appendString:[self formattedString:nil type:type level:0]];
    }

    return resultString;
}

- (NSDictionary *)formattedTypesForMethodName:(NSString *)name type:(NSString *)type;
{
    CDTypeParser *parser = [[CDTypeParser alloc] initWithString:type];

    NSError *error = nil;
    NSArray *methodTypes = [parser parseMethodType:&error];
    if (methodTypes == nil)
        CDLog(@"Warning: Parsing method types failed, %@", name);

    if (methodTypes == nil || [methodTypes count] == 0) {
        return nil;
    }

    NSMutableDictionary *typeDict = [NSMutableDictionary dictionary];
    {
        NSUInteger count = [methodTypes count];
        NSUInteger index = 0;
        BOOL noMoreTypes = NO;

        CDMethodType *methodType = methodTypes[index];
        NSString *specialCase = [self _specialCaseVariable:nil type:methodType.type.bareTypeString];
        if (specialCase != nil) {
            [typeDict setValue:specialCase forKey:@"return-type"];
        } else {
            NSString *str = [self formattedString:nil type:methodType.type level:0];
            if (str != nil)
                [typeDict setValue:str forKey:@"return-type"];
        }

        index += 3;

        NSMutableArray *parameterTypes = [NSMutableArray array];
        [typeDict setValue:parameterTypes forKey:@"parametertypes"];
        if (!name) {
            CDLogVerbose(@"%s NSScanner initWithString: %@", __PRETTY_FUNCTION__, name);
            name = @"";
        }
        NSScanner *scanner = [[NSScanner alloc] initWithString:name];
        while ([scanner isAtEnd] == NO) {
            NSString *str;

            // We can have unnamed parameters, :::
            if ([scanner scanUpToString:@":" intoString:&str]) {
                //CDLog(@"str += '%@'", str);
//				int unnamedCount, unnamedIndex;
//				unnamedCount = [str length];
//				for (unnamedIndex = 0; unnamedIndex < unnamedCount; unnamedIndex++)
//					[parameterTypes addObject:@{ @"type": @"", @"name": @""}];
            }
            if ([scanner scanString:@":" intoString:NULL]) {
                if (index >= count) {
                    noMoreTypes = YES;
                } else {
                    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];

                    methodType = methodTypes[index];
                    specialCase = [self _specialCaseVariable:nil type:methodType.type.bareTypeString];
                    if (specialCase != nil) {
                        [parameter setValue:specialCase forKey:@"type"];
                    } else {
//                        NSString *typeString = [methodType.type formattedString:nil formatter:self level:0];
                        NSString *typeString = [self formattedString:nil type:methodType.type level:0];
                        [parameter setValue:typeString forKey:@"type"];
                    }
                    //[parameter setValue:[NSString stringWithFormat:@"fp%@", methodType.offset] forKey:@"name"];
                    [parameter setValue:[NSString stringWithFormat:@"arg%lu", index-2] forKey:@"name"];
                    [parameterTypes addObject:parameter];
                    index++;
                }
            }
        }

        if (noMoreTypes) {
            CDLog(@" /* Error: Ran out of types for this method. */");
        }
    }

    return typeDict;
}

- (NSString *)formatMethodName:(NSString *)methodName typeString:(NSString *)typeString;
{
    CDTypeParser *parser = [[CDTypeParser alloc] initWithString:typeString];

    NSError *error = nil;
    NSArray *methodTypes = [parser parseMethodType:&error];
    if (methodTypes == nil)
        CDLog(@"Warning: Parsing method types failed, %@", methodName);

    if (methodTypes == nil || [methodTypes count] == 0) {
        return nil;
    }

    NSMutableString *resultString = [NSMutableString string];
    {
        NSUInteger count = [methodTypes count];
        NSUInteger index = 0;
        BOOL noMoreTypes = NO;

        CDMethodType *methodType = methodTypes[index];
        [resultString appendString:@"("];
        NSString *specialCase = [self _specialCaseVariable:nil type:methodType.type.bareTypeString];
        if (specialCase != nil) {
            [resultString appendString:specialCase];
        } else {
            NSString *str = [self formattedString:nil type:methodType.type level:0];
            if (str != nil)
                [resultString appendFormat:@"%@", str];
        }
        [resultString appendString:@")"];

        index += 3;
        if (!methodName) {
            CDLogVerbose(@"%s NSScanner initWithString: %@", __PRETTY_FUNCTION__, methodName);
            methodName = @"";
        }
        NSScanner *scanner = [[NSScanner alloc] initWithString:methodName];
        while ([scanner isAtEnd] == NO) {
            NSString *str;

            // We can have unnamed paramenters, :::
            if ([scanner scanUpToString:@":" intoString:&str]) {
                //CDLog(@"str += '%@'", str);
                [resultString appendString:str];
            }
            if ([scanner scanString:@":" intoString:NULL]) {
                [resultString appendString:@":"];
                if (index >= count) {
                    noMoreTypes = YES;
                } else {
                    methodType = methodTypes[index];
                    specialCase = [self _specialCaseVariable:nil type:methodType.type.bareTypeString];
                    if (specialCase != nil) {
                        [resultString appendFormat:@"(%@)", specialCase];
                    } else {
                        NSString *formattedType = [self formattedString:nil type:methodType.type level:0];
                        //if ([[methodType type] isIDType] == NO)
                        [resultString appendFormat:@"(%@)", formattedType];
                    }
                    //[resultString appendFormat:@"fp%@", [methodType offset]];
                    [resultString appendFormat:@"arg%lu", index-2];

                    NSString *ch = [scanner peekCharacter];
                    // if next character is not ':' nor EOS then add space
                    if (ch != nil && [ch isEqual:@":"] == NO)
                        [resultString appendString:@" "];
                    index++;
                }
            }
        }

        if (noMoreTypes) {
            [resultString appendString:@" /* Error: Ran out of types for this method. */"];
        }
    }

    return resultString;
}

// Called from CDType, which gets a formatter but not a type controller.
- (CDType *)replacementForType:(CDType *)type;
{
    return [self.delegate typeFormatter:self replacementForType:type];
}

// Called from CDType, which gets a formatter but not a type controller.
- (NSString *)typedefNameForStructure:(CDType *)structureType level:(NSUInteger)level;
{
    return [self.delegate typeFormatter:self typedefNameForStructure:structureType level:level];
}

- (void)formattingDidReferenceClassName:(NSString *)name;
{
    [self.delegate typeFormatter:self didReferenceClassName:name];
}

- (void)formattingDidReferenceProtocolNames:(NSArray *)names;
{
    [self.delegate typeFormatter:self didReferenceProtocolNames:names];
}



- (NSString *)formattedString:(NSString *)previousName type:(CDType *)type level:(NSUInteger)level;
{
    NSString *result, *currentName;
    NSString *baseType, *memberString;

    assert(type.variableName == nil || previousName == nil);
    if (type.variableName != nil)
        currentName = type.variableName;
    else
        currentName = previousName;
    
    if ([type.protocols count])
        [self formattingDidReferenceProtocolNames:type.protocols];

    switch (type.primitiveType) {
        case T_NAMED_OBJECT: {
            assert(type.typeName != nil);
            [self formattingDidReferenceClassName:type.typeName.name];

            NSString *typeName = nil;
            if (type.protocols == nil)
                typeName = [NSString stringWithFormat:@"%@", type.typeName];
            else
                typeName = [NSString stringWithFormat:@"%@<%@>", type.typeName, [type.protocols componentsJoinedByString:@", "]];

            if (currentName == nil)
                result = [NSString stringWithFormat:@"%@ *", typeName];
            else
                result = [NSString stringWithFormat:@"%@ *%@", typeName, currentName];
            break;
        }
        case '@':
            if (currentName == nil) {
                if (type.protocols == nil)
                    result = @"id";
                else
                    result = [NSString stringWithFormat:@"id <%@>", [type.protocols componentsJoinedByString:@", "]];
            } else {
                if (type.protocols == nil)
                    result = [NSString stringWithFormat:@"id %@", currentName];
                else
                    result = [NSString stringWithFormat:@"id <%@> %@", [type.protocols componentsJoinedByString:@", "], currentName];
            }
            break;
            
        case 'b':
            if (currentName == nil) {
                // This actually compiles!
                result = [NSString stringWithFormat:@"unsigned int :%@", type.bitfieldSize];
            } else
                result = [NSString stringWithFormat:@"unsigned int %@:%@", currentName, type.bitfieldSize];
            break;
            
        case '[':
            if (currentName == nil)
                result = [NSString stringWithFormat:@"[%@]", type.arraySize];
            else
                result = [NSString stringWithFormat:@"%@[%@]", currentName, type.arraySize];
            
            result = [self formattedString:result type:type.subtype level:level];
            break;
            
        case '(':
            baseType = nil;
            /*if (typeName == nil || [@"?" isEqual:[typeName description]])*/ {
                NSString *typedefName = [self typedefNameForStructure:type level:level];
                if (typedefName != nil) {
                    baseType = typedefName;
                }
            }
            
            if (baseType == nil) {
                if (type.typeName == nil || [@"?" isEqual:[type.typeName description]])
                    baseType = @"union";
                else
                    baseType = [NSString stringWithFormat:@"union %@", type.typeName];
                
                if ((self.shouldAutoExpand && [self.delegate shouldExpandType:type] && [type.members count] > 0)
                    || (level == 0 && self.shouldExpand && [type.members count] > 0))
                    memberString = [NSString stringWithFormat:@" {\n%@%@}",
                                    [self formattedStringForMembersAtLevel:level + 1 type:type],
                                    [NSString spacesIndentedToLevel:self.baseLevel + level spacesPerLevel:4]];
                else
                    memberString = @"";
                
                baseType = [baseType stringByAppendingString:memberString];
            }
            
            if (currentName == nil /*|| [currentName hasPrefix:@"?"]*/) // Not sure about this
                result = baseType;
            else
                result = [NSString stringWithFormat:@"%@ %@", baseType, currentName];
            break;
            
        case '{':
            baseType = nil;
            /*if (typeName == nil || [@"?" isEqual:[typeName description]])*/ {
                NSString *typedefName = [self typedefNameForStructure:type level:level];
                if (typedefName != nil) {
                    baseType = typedefName;
                }
            }
            if (baseType == nil) {
                if (type.typeName == nil || [@"?" isEqual:[type.typeName description]])
                    baseType = @"struct";
                else
                    baseType = [NSString stringWithFormat:@"struct %@", type.typeName];
                
                if ((self.shouldAutoExpand && [self.delegate shouldExpandType:type] && [type.members count] > 0)
                    || (level == 0 && self.shouldExpand && [type.members count] > 0))
                    memberString = [NSString stringWithFormat:@" {\n%@%@}",
                                    [self formattedStringForMembersAtLevel:level + 1 type:type],
                                    [NSString spacesIndentedToLevel:self.baseLevel + level spacesPerLevel:4]];
                else
                    memberString = @"";
                
                baseType = [baseType stringByAppendingString:memberString];
            }
            
            if (currentName == nil /*|| [currentName hasPrefix:@"?"]*/) // Not sure about this
                result = baseType;
            else
                result = [NSString stringWithFormat:@"%@ %@", baseType, currentName];
            break;
            
        case '^':
            if (currentName == nil)
                result = @"*";
            else
                result = [@"*" stringByAppendingString:currentName];
            
            if (type.subtype != nil && type.subtype.primitiveType == '[')
                result = [NSString stringWithFormat:@"(%@)", result];
            
            result = [self formattedString:result type:type.subtype level:level];
            break;
            
        case T_FUNCTION_POINTER_TYPE:
            if (currentName == nil)
                result = @"CDUnknownFunctionPointerType";
            else
                result = [NSString stringWithFormat:@"CDUnknownFunctionPointerType %@", currentName];
            break;
            
        case T_BLOCK_TYPE:
            if (type.types) {
                result = [self blockSignatureStringForType:type];
            } else {
                if (currentName == nil)
                    result = @"CDUnknownBlockType";
                else
                    result = [NSString stringWithFormat:@"CDUnknownBlockType %@", currentName];
            }
            break;
            
        case 'j':
        case 'r':
        case 'n':
        case 'N':
        case 'o':
        case 'O':
        case 'R':
        case 'V':
        case 'A':
            if (type.subtype == nil) {
                if (currentName == nil)
                    result = [self formattedStringForSimpleType:type];
                else
                    result = [NSString stringWithFormat:@"%@ %@", [self formattedStringForSimpleType:type], currentName];
            } else
                result = [NSString stringWithFormat:@"%@ %@",
                          [self formattedStringForSimpleType:type], [self formattedString:currentName type:type.subtype level:level]];
            break;
            
        default:
            if (currentName == nil)
                result = [self formattedStringForSimpleType:type];
            else
                result = [NSString stringWithFormat:@"%@ %@", [self formattedStringForSimpleType:type], currentName];
            break;
    }
    
    return result;
}

- (NSString *)formattedStringForMembersAtLevel:(NSUInteger)level type:(CDType *)type;
{
    NSParameterAssert(type.primitiveType == '{' || type.primitiveType == '(');
    NSMutableString *str = [NSMutableString string];

    for (CDType *member in type.members) {
        [str appendString:[NSString spacesIndentedToLevel:self.baseLevel + level spacesPerLevel:4]];
        [str appendString:[self formattedString:nil
                                           type:member
                                  level:level]];
        [str appendString:@";\n"];
    }

    return str;
}

- (NSString *)formattedStringForSimpleType:(CDType *)type;
{
    // Ugly but simple:
    switch (type.primitiveType) {
        case 'c': return @"char";
        case 'i': return @"int";
        case 's': return @"short";
        case 'l': return self.configuration.shouldUseNSIntegerTypedef ? @"NSInteger" : @"long";
        case 'q': return self.configuration.shouldUseNSIntegerTypedef ? @"NSInteger" : @"long long";
        case 'C': return @"unsigned char";
        case 'I': return @"unsigned int";
        case 'S': return @"unsigned short";
        case 'L': return self.configuration.shouldUseNSUIntegerTypedef ? @"NSUInteger" : @"unsigned long";
        case 'Q': return self.configuration.shouldUseNSUIntegerTypedef ? @"NSUInteger" : @"unsigned long long";
        case 'f': return @"float";
        case 'd': return @"double";
        case 'D': return @"long double";
        case 'B': return self.configuration.shouldUseBOOLTypedef ? @"BOOL" : @"_Bool"; // C99 _Bool or C++ bool
        case 'v': return @"void";
        case '*': return @"STR";
        case '#': return @"Class";
        case ':': return @"SEL";
        case '%': return @"NXAtom";
        case '?': return @"void"; //case '?': return @"UNKNOWN"; // For easier regression testing.
        case 'j': return @"_Complex";
        case 'r': return @"const";
        case 'n': return @"in";
        case 'N': return @"inout";
        case 'o': return @"out";
        case 'O': return @"bycopy";
        case 'R': return @"byref";
        case 'V': return @"oneway";
        case 'A': return @"_Atomic";
        default:
            break;
    }

    return nil;
}

- (NSString *)blockSignatureStringForType:(CDType *)targetType;
{
    NSMutableString *blockSignatureString = [[NSMutableString alloc] init];
    CDTypeFormatter *blockSignatureTypeFormatter = [[CDTypeFormatter alloc] initWithConfiguration:_configuration];
    blockSignatureTypeFormatter.shouldExpand = NO;
    blockSignatureTypeFormatter.shouldAutoExpand = NO;
    blockSignatureTypeFormatter.baseLevel = 0;
    [targetType.types enumerateObjectsUsingBlock:^(CDType *type, NSUInteger idx, BOOL *stop) {
        if (idx != 1)
            [blockSignatureString appendString:[blockSignatureTypeFormatter formatVariable:nil type:type]];
        else
            [blockSignatureString appendString:@"(^)"];
        
        BOOL isLastType = idx == [targetType.types count] - 1;
        
        if (idx == 0)
            [blockSignatureString appendString:@" "];
        else if (idx == 1)
            [blockSignatureString appendString:@"("];
        else if (idx >= 2 && !isLastType)
            [blockSignatureString appendString:@", "];
        
        if (isLastType) {
            if ([targetType.types count] == 2) {
                [blockSignatureString appendString:@"void"];
            }
            [blockSignatureString appendString:@")"];
        }
    }];
    
    return blockSignatureString;
}

@end
