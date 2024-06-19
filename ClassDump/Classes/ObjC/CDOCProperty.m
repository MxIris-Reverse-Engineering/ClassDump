// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDOCProperty.h>
#import <ClassDump/CDOCPropertyAttribute.h>
#import <ClassDump/CDTypeParser.h>
#import <ClassDump/CDTypeLexer.h>
#import <ClassDump/CDType.h>
#import <ClassDump/NSString-CDExtensions.h>
#import <ClassDump/ClassDumpUtils.h>
// http://developer.apple.com/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html



@implementation CDOCProperty
{
    NSString *_name;
    NSString *_attributeString;
    
    CDType *_type;
    NSMutableArray<NSString *> *_attributes;
    NSMutableArray<CDOCPropertyAttribute *> *_detailAttributes;
    
    NSMutableArray<NSString *> *_unknownAttributes;
    
    BOOL _hasParsedAttributes;
    NSString *_attributeStringAfterType;
    NSString *_customGetter;
    NSString *_customSetter;
    
    BOOL _isReadOnly;
    BOOL _isDynamic;
}

- (instancetype)initWithName:(NSString *)name attributes:(NSString *)attributes {
    return [self initWithName:name attributes:attributes isClass:NO];
}

- (instancetype)initWithName:(NSString *)name attributes:(NSString *)attributes isClass:(BOOL)isClass;
{
    if ((self = [super init])) {
        _name = name;
        _attributeString = attributes;
        _type = nil;
        _attributes = [[NSMutableArray alloc] init];
        
        _hasParsedAttributes = NO;
        _attributeStringAfterType = nil;
        _customGetter = nil;
        _customSetter = nil;
        
        _isReadOnly = NO;
        _isDynamic = NO;
        _isClass = isClass;
        
        [self _parseAttributes];
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@:%p> name: %@, attributeString: %@",
            NSStringFromClass([self class]), self,
            self.name, self.attributeString];
}

#pragma mark -

- (NSString *)defaultGetter;
{
    return self.name;
}

- (NSString *)defaultSetter;
{
    return [NSString stringWithFormat:@"set%@:", [self.name capitalizeFirstCharacter]];
}

- (NSString *)getter;
{
    if (self.customGetter != nil)
        return self.customGetter;

    return self.defaultGetter;
}

- (NSString *)setter;
{
    if (self.customSetter != nil)
        return self.customSetter;

    return self.defaultSetter;
}

#pragma mark - Sorting

- (NSComparisonResult)ascendingCompareByName:(CDOCProperty *)other;
{
    return [self.name compare:other.name];
}

#pragma mark -

// TODO: (2009-07-09) Really, I don't need to require the "T" at the start.
- (void)_parseAttributes;
{
    // On 10.6, Finder's TTaskErrorViewController class has a property with a nasty C++ type.  I just knew someone would make this difficult.
    if (!self.attributeString) {
        CDLogVerbose(@"%s NSScanner initWithString: %@", __PRETTY_FUNCTION__, self.attributeString);
        return;
    }
    NSScanner *scanner = [[NSScanner alloc] initWithString:self.attributeString];

    if ([scanner scanString:@"T" intoString:NULL]) {
        NSError *error = nil;
        NSRange typeRange;

        typeRange.location = [scanner scanLocation];
        CDTypeParser *parser = [[CDTypeParser alloc] initWithString:[[scanner string] substringFromIndex:[scanner scanLocation]]];
        _type = [parser parseType:&error];
        if (_type != nil) {
            typeRange.length = [parser.lexer.scanner scanLocation];

            NSString *str = [self.attributeString substringFromIndex:NSMaxRange(typeRange)];

            // Filter out so we don't get an empty string as an attribute.
            if ([str hasPrefix:@","])
                str = [str substringFromIndex:1];

            _attributeStringAfterType = str;
            if ([self.attributeStringAfterType length] > 0) {
                [_attributes addObjectsFromArray:[self.attributeStringAfterType componentsSeparatedByString:@","]];
            } else {
                // For a simple case like "Ti", we'd get the empty string.
                // Then, using componentsSeparatedByString:, since it has no separator we'd get back an array containing the (empty) string
            }
        }
    } else {
        CDLogVerbose(@"Error: Property attributes should begin with the type ('T') attribute, property name: %@", self.name);
    }

//    for (NSString *attr in _attributes) {
//        if ([attr hasPrefix:@"R"])
//            _isReadOnly = YES;
//        else if ([attr hasPrefix:@"D"])
//            _isDynamic = YES;
//        else if ([attr hasPrefix:@"G"])
//            self.customGetter = [attr substringFromIndex:1];
//        else if ([attr hasPrefix:@"S"])
//            self.customSetter = [attr substringFromIndex:1];
//    }

//    BOOL isReadOnly = NO, isDynamic = NO;
    NSMutableArray<NSString *> *unknownAttributes = [NSMutableArray array];
    NSMutableArray<CDOCPropertyAttribute *> *detailAttributes = [NSMutableArray array];
    if (_isClass) {
        [detailAttributes addObject:[CDOCPropertyAttribute attributeWithName:@"class" value:nil type:CDOCPropertyAttributeTypeClass]];
    }
    
    const char *const propAttribs = self.attributeString.UTF8String;
    
    for (const char *propSeek = propAttribs; propSeek < (propAttribs + strlen(propAttribs)); propSeek++) {
        const char switchOnMe = *propSeek++;
        
        NSString *attributeName = nil;
        NSString *attributeValue = nil;
        CDOCPropertyAttributeType attributeType = nil;
        
        const char *const attribHead = propSeek;
        while (*propSeek && *propSeek != ',') {
            switch (*propSeek) {
                case '"': {
                    propSeek = strchr(++propSeek, '"');
                } break;
                case '{': {
                    unsigned openTokens = 1;
                    while (openTokens) {
                        switch (*++propSeek) {
                            case '{':
                                openTokens++;
                                break;
                            case '}':
                                openTokens--;
                                break;
                        }
                    }
                } break;
                case '(': {
                    unsigned openTokens = 1;
                    while (openTokens) {
                        switch (*++propSeek) {
                            case '(':
                                openTokens++;
                                break;
                            case ')':
                                openTokens--;
                                break;
                        }
                    }
                } break;
            }
            propSeek++;
        }
        
        NSUInteger const valueLen = propSeek - attribHead;
        if (valueLen > 0) {
            attributeValue = [[NSString alloc] initWithBytes:attribHead length:valueLen encoding:NSUTF8StringEncoding];
        }
        
        /* per https://github.com/llvm/llvm-project/blob/b7f97d3661/clang/lib/AST/ASTContext.cpp#L7878-L7973
         *
         *  enum PropertyAttributes {
         *      kPropertyReadOnly          = 'R', // property is read-only.
         *      kPropertyBycopy            = 'C', // property is a copy of the value last assigned
         *      kPropertyByref             = '&', // property is a reference to the value last assigned
         *      kPropertyDynamic           = 'D', // property is dynamic
         *      kPropertyGetter            = 'G', // followed by getter selector name
         *      kPropertySetter            = 'S', // followed by setter selector name
         *      kPropertyInstanceVariable  = 'V', // followed by instance variable  name
         *      kPropertyType              = 'T', // followed by old-style type encoding.
         *      kPropertyWeak              = 'W', // 'weak' property
         *      kPropertyStrong            = 'P', // property GC'able
         *      kPropertyNonAtomic         = 'N', // property non-atomic
         *      kPropertyOptional          = '?', // property optional
         * };
         */
        switch (switchOnMe) {
            case 'R':
                attributeName = @"readonly";
                attributeType = CDOCPropertyAttributeTypeReadwrite;
                _isReadOnly = YES;
                break;
            case 'C':
                attributeName = @"copy";
                attributeType = CDOCPropertyAttributeTypeReference;
                break;
            case '&':
                attributeName = @"strong";
                attributeType = CDOCPropertyAttributeTypeReference;
                break;
            case 'D':
                _isDynamic = YES;
                break;
            case 'G':
                attributeName = @"getter";
                attributeType = CDOCPropertyAttributeTypeGetter;
                _customGetter = attributeValue;
                break;
            case 'S':
                attributeName = @"setter";
                attributeType = CDOCPropertyAttributeTypeSetter;
                _customSetter = attributeValue;
                break;
            case 'V':
                _ivar = attributeValue;
                break;
            case 'T':
//                _type = [CDTypeParser typeForEncodingStart:attribHead end:propSeek error:NULL];
                continue;
                break;
            case 'W':
                attributeName = @"weak";
                attributeType = CDOCPropertyAttributeTypeReference;
                break;
            case 'P':
                // eligible for garbage collection, no notation
                break;
            case 'N':
                attributeName = @"nonatomic";
                attributeType = CDOCPropertyAttributeTypeThreadSafe;
                break;
            case '?':
                // @optional in a protocol
                break;
            default:
                [unknownAttributes addObject:[NSString stringWithFormat:@"%c", switchOnMe]];
                break;
        }
        
        if (attributeName && attributeType) {
            [detailAttributes addObject:[CDOCPropertyAttribute attributeWithName:attributeName value:attributeValue type:attributeType]];
        }
    }
    _detailAttributes = detailAttributes;
    _unknownAttributes = unknownAttributes;
    _hasParsedAttributes = YES;
    // And then if parsedType is nil, we know we couldn't parse the type.
}

- (void)appendToString:(NSMutableString *)resultString typeController:(CDTypeController *)typeController {
    
}

@end
