// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDType.h>

#import <ClassDump/CDTypeController.h>
#import <ClassDump/CDTypeName.h>
#import <ClassDump/CDTypeLexer.h> // For T_NAMED_OBJECT
#import <ClassDump/CDTypeFormatter.h>
#import <ClassDump/CDTypeParser.h>
#import <ClassDump/NSString-CDExtensions.h>
#import <ClassDump/ClassDumpUtils.h>
#import <ClassDump/CDClassDumpConfiguration.h>

static BOOL debugMerge = NO;

@interface CDType ()
//@property (nonatomic, readonly) NSString *formattedStringForSimpleType;
@end

#pragma mark -

// primitive types:
// * gets turned into ^c (i.e. char *)
// T_NAMED_OBJECT w/ _typeName as the name
// @ - id
// { - structure w/ _typeName, members
// ( - union     w/ _typeName, members
// b - bitfield  w/ _bitfieldSize          - can these occur anywhere, or just in structures/unions?
// [ - array     w/ _arraySize, _subtype
// ^ - poiner to _subtype
// C++ template type...

// Primitive types:
// c: char
// i: int
// s: short
// l: long
// q: long long
// C: unsigned char
// I: unsigned int
// S: unsigned short
// L: unsigned long
// Q: unsigned long long
// f: float
// d: double
// D: long double
// B: _Bool // C99 _Bool or C++ bool
// v: void
// #: Class
// :: SEL
// %: NXAtom
// ?: void
//case '?': return @"UNKNOWN"; // For easier regression testing.
// j: _Complex - is this a modifier or a primitive type?
//
// modifier (which?) w/ _subtype.  Can we limit these to the top level of the type?
//   - n - in
//   - N - inout
//   - o - out
//   - O - bycopy
//   - R - byref
//   - V - oneway
// const is probably different from the previous modifiers.  You can have const int * const foo, or something like that.
//   - r - const


@implementation CDType
{
    int _primitiveType;
    NSArray *_protocols;
    CDType *_subtype;
    CDTypeName *_typeName;
    NSMutableArray *_members;
    NSString *_bitfieldSize;
    NSString *_arraySize;
    
    NSString *_variableName;
}

- (instancetype)initSimpleType:(int)type;
{
    if ((self = [self init])) {
        if (type == '*') {
            _primitiveType = '^';
            _subtype = [[CDType alloc] initSimpleType:'c'];
        } else {
            _primitiveType = type;
        }
    }

    return self;
}

- (instancetype)initIDType:(CDTypeName *)name;
{
    return [self initIDType:name withProtocols:nil];
}

- (instancetype)initIDType:(CDTypeName *)name withProtocols:(NSArray *)protocols;
{
    if ((self = [self init])) {
        if (name != nil) {
            _primitiveType = T_NAMED_OBJECT;
            _typeName = name;
        } else {
            _primitiveType = '@';
        }
        _protocols = protocols;
    }
    
    return self;
}

- (instancetype)initIDTypeWithProtocols:(NSArray *)protocols;
{
    if ((self = [self init])) {
        _primitiveType = '@';
        _protocols = protocols;
    }

    return self;
}

- (instancetype)initStructType:(CDTypeName *)name members:(NSArray *)members;
{
    if ((self = [self init])) {
        _primitiveType = '{';
        _typeName = name;
        _members = [[NSMutableArray alloc] initWithArray:members];
    }

    return self;
}

- (instancetype)initUnionType:(CDTypeName *)name members:(NSArray *)members;
{
    if ((self = [self init])) {
        _primitiveType = '(';
        _typeName = name;
        _members = [[NSMutableArray alloc] initWithArray:members];
    }

    return self;
}

- (instancetype)initBitfieldType:(NSString *)bitfieldSize;
{
    if ((self = [self init])) {
        _primitiveType = 'b';
        _bitfieldSize = bitfieldSize;
    }

    return self;
}

- (instancetype)initArrayType:(CDType *)type count:(NSString *)count;
{
    if ((self = [self init])) {
        _primitiveType = '[';
        _arraySize = count;
        _subtype = type;
    }

    return self;
}

- (instancetype)initPointerType:(CDType *)type;
{
    if ((self = [self init])) {
        _primitiveType = '^';
        _subtype = type;
    }

    return self;
}

- (instancetype)initFunctionPointerType;
{
    if ((self = [self init])) {
        _primitiveType = T_FUNCTION_POINTER_TYPE;
    }

    return self;
}

- (instancetype)initBlockTypeWithTypes:(NSArray *)types;
{
    if ((self = [self init])) {
        _primitiveType = T_BLOCK_TYPE;
        _types = types;
    }

    return self;
}

- (instancetype)initModifier:(int)modifier type:(CDType *)type;
{
    if ((self = [self init])) {
        _primitiveType = modifier;
        _subtype = type;
    }

    return self;
}

#pragma mark - NSCopying

// An easy deep copy.
- (id)copyWithZone:(NSZone *)zone;
{
    NSString *str = [self typeString];
    NSParameterAssert(str != nil);
    
    CDTypeParser *parser = [[CDTypeParser alloc] initWithString:str];

    NSError *error = nil;
    CDType *copiedType = [parser parseType:&error];
    if (copiedType == nil)
        CDLog(@"Warning: Parsing type in %s failed, %@", __PRETTY_FUNCTION__, str);
    
    NSParameterAssert([str isEqualToString:copiedType.typeString]);
    
    copiedType.variableName = _variableName;
    
    return copiedType;
}

#pragma mark -

// TODO: (2009-08-26) Looks like this doesn't compare the variable name.
- (BOOL)isEqual:(id)object;
{
    if ([object isKindOfClass:[self class]]) {
        CDType *otherType = object;
        return [self.typeString isEqual:otherType.typeString];
    }
    
    return NO;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"[%@] type: %d('%c'), name: %@, subtype: %@, bitfieldSize: %@, arraySize: %@, members: %@, variableName: %@",
            NSStringFromClass([self class]), _primitiveType, _primitiveType, _typeName, _subtype, _bitfieldSize, _arraySize, _members, _variableName];
}

#pragma mark -

- (BOOL)isIDType;
{
    return _primitiveType == '@' && _typeName == nil;
}

- (BOOL)isNamedObject;
{
    return _primitiveType == T_NAMED_OBJECT;
}

- (BOOL)isTemplateType;
{
    return _typeName.isTemplateType;
}

- (BOOL)isModifierType;
{
    return _primitiveType == 'j' || _primitiveType == 'r' || _primitiveType == 'n' || _primitiveType == 'N' || _primitiveType == 'o' || _primitiveType == 'O' || _primitiveType == 'R' || _primitiveType == 'V' || _primitiveType == 'A';
}

- (int)typeIgnoringModifiers;
{
    if (self.isModifierType && _subtype != nil)
        return _subtype.typeIgnoringModifiers;

    return _primitiveType;
}

- (NSUInteger)structureDepth;
{
    if (_subtype != nil)
        return _subtype.structureDepth;

    if (_primitiveType == '{' || _primitiveType == '(') {
        NSUInteger maxDepth = 0;

        for (CDType *member in _members) {
            if (maxDepth < member.structureDepth)
                maxDepth = member.structureDepth;
        }

        return maxDepth + 1;
    }

    return 0;
}


- (NSString *)typeString;
{
    return [self _typeStringWithVariableNamesToLevel:1e6 showObjectTypes:YES];
}

- (NSString *)bareTypeString;
{
    return [self _typeStringWithVariableNamesToLevel:0 showObjectTypes:YES];
}

- (NSString *)reallyBareTypeString;
{
    return [self _typeStringWithVariableNamesToLevel:0 showObjectTypes:NO];
}

- (NSString *)keyTypeString;
{
    // use variable names at top level
    return [self _typeStringWithVariableNamesToLevel:1 showObjectTypes:YES];
}

- (NSString *)_typeStringWithVariableNamesToLevel:(NSUInteger)level showObjectTypes:(BOOL)shouldShowObjectTypes;
{
    NSString *result;
    
    switch (_primitiveType) {
        case T_NAMED_OBJECT:
            assert(_typeName != nil);
            if (shouldShowObjectTypes)
                result = [NSString stringWithFormat:@"@\"%@\"", _typeName];
            else
                result = @"@";
            break;
            
        case '@':
            result = @"@";
            break;
            
        case 'b':
            result = [NSString stringWithFormat:@"b%@", _bitfieldSize];
            break;
            
        case '[':
            result = [NSString stringWithFormat:@"[%@%@]", _arraySize, [_subtype _typeStringWithVariableNamesToLevel:level showObjectTypes:shouldShowObjectTypes]];
            break;
            
        case '(':
            if (_typeName == nil) {
                return [NSString stringWithFormat:@"(%@)", [self _typeStringForMembersWithVariableNamesToLevel:level showObjectTypes:shouldShowObjectTypes]];
            } else if ([_members count] == 0) {
                return [NSString stringWithFormat:@"(%@)", _typeName];
            } else {
                return [NSString stringWithFormat:@"(%@=%@)", _typeName, [self _typeStringForMembersWithVariableNamesToLevel:level showObjectTypes:shouldShowObjectTypes]];
            }
            
        case '{':
            if (_typeName == nil) {
                return [NSString stringWithFormat:@"{%@}", [self _typeStringForMembersWithVariableNamesToLevel:level showObjectTypes:shouldShowObjectTypes]];
            } else if ([_members count] == 0) {
                return [NSString stringWithFormat:@"{%@}", _typeName];
            } else {
                return [NSString stringWithFormat:@"{%@=%@}", _typeName, [self _typeStringForMembersWithVariableNamesToLevel:level showObjectTypes:shouldShowObjectTypes]];
            }
            
        case '^':
            result = [NSString stringWithFormat:@"^%@", [_subtype _typeStringWithVariableNamesToLevel:level showObjectTypes:shouldShowObjectTypes]];
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
            result = [NSString stringWithFormat:@"%c%@", _primitiveType, [_subtype _typeStringWithVariableNamesToLevel:level showObjectTypes:shouldShowObjectTypes]];
            break;
            
        case T_FUNCTION_POINTER_TYPE:
            result = @"^?";
            break;
            
        case T_BLOCK_TYPE:
            result = @"@?";
            break;
            
        default:
            result = [NSString stringWithFormat:@"%c", _primitiveType];
            break;
    }

    return result;
}

- (NSString *)_typeStringForMembersWithVariableNamesToLevel:(NSInteger)level showObjectTypes:(BOOL)shouldShowObjectTypes;
{
    NSParameterAssert(_primitiveType == '{' || _primitiveType == '(');
    NSMutableString *str = [NSMutableString string];

    for (CDType *member in _members) {
        if (member.variableName != nil && level > 0)
            [str appendFormat:@"\"%@\"", member.variableName];
        [str appendString:[member _typeStringWithVariableNamesToLevel:level - 1 showObjectTypes:shouldShowObjectTypes]];
    }

    return str;
}

- (BOOL)canMergeWithType:(CDType *)otherType;
{
    if (self.isIDType && otherType.isNamedObject)
        return YES;

    if (self.isNamedObject && otherType.isIDType) {
        return YES;
    }

    if (_primitiveType != otherType.primitiveType) {
        if (debugMerge) {
            CDLog(@"--------------------");
            CDLog(@"this: %@", self.typeString);
            CDLog(@"other: %@", otherType.typeString);
            CDLog(@"self isIDType? %u", self.isIDType);
            CDLog(@"self isNamedObject? %u", self.isNamedObject);
            CDLog(@"other isIDType? %u", otherType.isIDType);
            CDLog(@"other isNamedObject? %u", otherType.isNamedObject);
        }
        if (debugMerge) CDLog(@"%s, Can't merge because of type... %@ vs %@", __PRETTY_FUNCTION__, self.typeString, otherType.typeString);
        return NO;
    }

    if (_subtype != nil && [_subtype canMergeWithType:otherType.subtype] == NO) {
        if (debugMerge) CDLog(@"%s, Can't merge subtype", __PRETTY_FUNCTION__);
        return NO;
    }

    if (_subtype == nil && otherType.subtype != nil) {
        if (debugMerge) CDLog(@"%s, This subtype is nil, other isn't.", __PRETTY_FUNCTION__);
        return NO;
    }

    NSArray *otherMembers = otherType.members;
    NSUInteger count = [_members count];
    NSUInteger otherCount = [otherMembers count];

    //CDLog(@"members: %p", members);
    //CDLog(@"otherMembers: %p", otherMembers);
    //CDLog(@"%s, count: %u, otherCount: %u", __PRETTY_FUNCTION__, count, otherCount);

    if (count != 0 && otherCount == 0) {
        if (debugMerge) CDLog(@"%s, count != 0 && otherCount is 0", __PRETTY_FUNCTION__);
        return NO;
    }

    if (count != 0 && count != otherCount) {
        if (debugMerge) CDLog(@"%s, count != 0 && count != otherCount", __PRETTY_FUNCTION__);
        return NO;
    }

    // count == 0 is ok: we just have a name in that case.
    if (count == otherCount) {
        for (NSUInteger index = 0; index < count; index++) { // Oooh
            CDType *thisMember = _members[index];
            CDType *otherMember = otherMembers[index];

            CDTypeName *thisTypeName = thisMember.typeName;
            CDTypeName *otherTypeName = otherMember.typeName;
            NSString *thisVariableName = thisMember.variableName;
            NSString *otherVariableName = otherMember.variableName;

            // It seems to be okay if one of them didn't have a name
            if (thisTypeName != nil && otherTypeName != nil && [thisTypeName isEqual:otherTypeName] == NO) {
                if (debugMerge) CDLog(@"%s, typeName mismatch on member %lu", __PRETTY_FUNCTION__, index);
                return NO;
            }

            if (thisVariableName != nil && otherVariableName != nil && [thisVariableName isEqual:otherVariableName] == NO) {
                if (debugMerge) CDLog(@"%s, variableName mismatch on member %lu", __PRETTY_FUNCTION__, index);
                return NO;
            }

            if ([thisMember canMergeWithType:otherMember] == NO) {
                if (debugMerge) CDLog(@"%s, Can't merge member %lu", __PRETTY_FUNCTION__, index);
                return NO;
            }
        }
    }

    return YES;
}

// Merge struct/union member names.  Should check using -canMergeWithType: first.
// Recursively merges, not just the top level.
- (void)mergeWithType:(CDType *)otherType;
{
    NSString *before = self.typeString;
    [self _recursivelyMergeWithType:otherType];
    NSString *after = self.typeString;
    if (debugMerge) {
        CDLog(@"----------------------------------------");
        CDLog(@"%s", __PRETTY_FUNCTION__);
        CDLog(@"before: %@", before);
        CDLog(@" after: %@", after);
        CDLog(@"----------------------------------------");
    }
}

- (void)_recursivelyMergeWithType:(CDType *)otherType;
{
    if (self.isIDType && otherType.isNamedObject) {
        //CDLog(@"thisType: %@", [self typeString]);
        //CDLog(@"otherType: %@", [otherType typeString]);
        _primitiveType = T_NAMED_OBJECT;
        _typeName = [otherType.typeName copy];
        return;
    }

    if (self.isNamedObject && otherType.isIDType) {
        return;
    }

    if (_primitiveType != otherType.primitiveType) {
        CDLog(@"Warning: Trying to merge different types in %s", __PRETTY_FUNCTION__);
        return;
    }

    [_subtype _recursivelyMergeWithType:otherType.subtype];

    NSArray *otherMembers = otherType.members;
    NSUInteger count = [_members count];
    NSUInteger otherCount = [otherMembers count];

    // The counts can be zero when we register structures that just have a name.  That happened while I was working on the
    // structure registration.
    if (otherCount == 0) {
        return;
    } else if (count == 0 && otherCount != 0) {
        NSParameterAssert(_members != nil);
        [_members removeAllObjects];
        [_members addObjectsFromArray:otherMembers];
        //[self setMembers:otherMembers];
    } else if (count != otherCount) {
        // Not so bad after all.  Even kind of common.  Consider _flags.
        CDLog(@"Warning: Types have different number of members.  This is bad. (%lu vs %lu)", count, otherCount);
        CDLog(@"%@ vs %@", self.typeString, otherType.typeString);
        return;
    }

    //CDLog(@"****************************************");
    for (NSUInteger index = 0; index < count; index++) {
        CDType *thisMember = _members[index];
        CDType *otherMember = otherMembers[index];

        CDTypeName *thisTypeName = thisMember.typeName;
        CDTypeName *otherTypeName = otherMember.typeName;
        NSString *thisVariableName = thisMember.variableName;
        NSString *otherVariableName = otherMember.variableName;
        //CDLog(@"%d: type: %@ vs %@", index, thisTypeName, otherTypeName);
        //CDLog(@"%d: vari: %@ vs %@", index, thisVariableName, otherVariableName);

        if ((thisTypeName == nil && otherTypeName != nil) || (thisTypeName != nil && otherTypeName == nil)) {
            ; // It seems to be okay if one of them didn't have a name
            //CDLog(@"Warning: (1) type names don't match, %@ vs %@", thisTypeName, otherTypeName);
        } else if (thisTypeName != nil && [thisTypeName isEqual:otherTypeName] == NO) {
            CDLog(@"Warning: (2) type names don't match:\n\t%@ vs \n\t%@.", thisTypeName, otherTypeName);
            // In this case, we should skip the merge.
        }

        if (otherVariableName != nil) {
            if (thisVariableName == nil)
                thisMember.variableName = otherVariableName;
            else if ([thisVariableName isEqual:otherVariableName] == NO)
                CDLog(@"Warning: Different variable names for same member...");
        }

        [thisMember _recursivelyMergeWithType:otherMember];
    }
}

- (NSArray *)memberVariableNames;
{
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [_members enumerateObjectsUsingBlock:^(CDType *memberType, NSUInteger index, BOOL *stop){
        if (memberType.variableName != nil)
            [names addObject:memberType.variableName];
    }];
    
    return [names copy];
}

- (void)generateMemberNames;
{
    if (_primitiveType == '{' || _primitiveType == '(') {
        NSSet *usedNames = [[NSSet alloc] initWithArray:self.memberVariableNames];

        NSUInteger number = 1;
        for (CDType *member in _members) {
            [member generateMemberNames];

            // Bitfields don't need a name.
            if (member.variableName == nil && member.primitiveType != 'b') {
                NSString *name;
                do {
                    name = [NSString stringWithFormat:@"_field%lu", number++];
                } while ([usedNames containsObject:name]);
                member.variableName = name;
            }
        }
    }

    [_subtype generateMemberNames];
}

- (void)phase0RecursivelyFixStructureNames;
{
    [_subtype phase0RecursivelyFixStructureNames];

    if ([_typeName.name hasPrefix:@"$"]) {
//        if (flag) CDLog(@"%s, changing type name %@ to ?", __PRETTY_FUNCTION__, type.typeName.name);
        _typeName.name = @"?";
    }

    for (CDType *member in _members) {
        [member phase0RecursivelyFixStructureNames];
    }
}


@end
