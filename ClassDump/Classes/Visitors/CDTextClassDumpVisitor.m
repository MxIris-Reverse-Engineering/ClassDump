// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDTextClassDumpVisitor.h>

#import <ClassDump/CDClassDump.h>
#import <ClassDump/CDOCClass.h>
#import <ClassDump/CDOCCategory.h>
#import <ClassDump/CDOCMethod.h>
#import <ClassDump/CDOCProperty.h>
#import <ClassDump/CDTypeController.h>
#import <ClassDump/CDTypeFormatter.h>
#import <ClassDump/CDVisitorPropertyState.h>
#import <ClassDump/CDOCInstanceVariable.h>
#import <ClassDump/ClassDumpUtils.h>
#import <ClassDump/CDExtensions.h>
#import <ClassDump/CDClassDumpConfiguration.h>

@interface CDTextClassDumpVisitor ()
@end

#pragma mark -

@implementation CDTextClassDumpVisitor
{
    NSMutableString *_resultString;
}

- (instancetype)init;
{
    if ((self = [super init])) {
        _resultString = [[NSMutableString alloc] init];
    }

    return self;
}

#pragma mark -

- (void)willVisitClass:(CDOCClass *)aClass;
{
    if (aClass.isExported == NO)
        [self.resultString appendString:@"__attribute__((visibility(\"hidden\")))\n"];

    [self.resultString appendFormat:@"@interface %@", aClass.name];
    if (aClass.superClassName != nil)
        [self.resultString appendFormat:@" : %@", aClass.superClassName];

    NSArray *protocols = aClass.protocols;
    if ([protocols count] > 0) {
        [self.resultString appendFormat:@" <%@>", aClass.protocolsString];
    }

    [self.resultString appendString:@"\n\n"];
}

- (void)didVisitClass:(CDOCClass *)aClass;
{
    if (aClass.hasMethods)
        [self.resultString appendString:@"\n"];

    [self.resultString appendString:@"@end\n\n"];
}

- (void)willVisitIvarsOfClass:(CDOCClass *)aClass;
{
    // remove last \n
    [self.resultString deleteCharactersInRange:NSMakeRange(self.resultString.length - 1, 1)];
    [self.resultString appendString:@"{\n"];
}

- (void)didVisitIvarsOfClass:(CDOCClass *)aClass;
{
    [self.resultString appendString:@"}\n\n"];
}

- (void)willVisitCategory:(CDOCCategory *)category;
{
    [self.resultString appendFormat:@"@interface %@ (%@)", category.className, category.name];

    NSArray *protocols = category.protocols;
    if ([protocols count] > 0) {
        [self.resultString appendFormat:@" <%@>", category.protocolsString];
    }

    [self.resultString appendString:@"\n"];
}

- (void)didVisitCategory:(CDOCCategory *)category;
{
    [self.resultString appendString:@"@end\n\n"];
}

- (void)willVisitProtocol:(CDOCProtocol *)protocol;
{
    [self.resultString appendFormat:@"@protocol %@", protocol.name];

    NSArray *protocols = protocol.protocols;
    if ([protocols count] > 0) {
        [self.resultString appendFormat:@" <%@>", protocol.protocolsString];
    }

    [self.resultString appendString:@"\n"];
}

- (void)willVisitOptionalMethods;
{
    [self.resultString appendString:@"\n@optional\n"];
}

- (void)didVisitProtocol:(CDOCProtocol *)protocol;
{
    [self.resultString appendString:@"@end\n\n"];
}

- (void)visitClassMethod:(CDOCMethod *)method;
{
    [self.resultString appendString:@"+ "];
    [method appendToString:self.resultString typeController:self.classDump.typeController];
    [self.resultString appendString:@"\n"];
}

- (void)visitInstanceMethod:(CDOCMethod *)method propertyState:(CDVisitorPropertyState *)propertyState;
{
//    CDOCProperty *property = [propertyState propertyForAccessor:method.name];
//    if (property == nil) {
        //CDLog(@"No property for method: %@", method.name);
        [self.resultString appendString:@"- "];
        [method appendToString:self.resultString typeController:self.classDump.typeController];
        [self.resultString appendString:@"\n"];
//    } else {
//        if ([propertyState hasUsedProperty:property] == NO) {
            //CDLog(@"Emitting property %@ triggered by method %@", property.name, method.name);
//            [self visitProperty:property];
//            [propertyState useProperty:property];
//        } else {
            //CDLog(@"Have already emitted property %@ triggered by method %@", property.name, method.name);
//        }
//    }
}

- (void)visitIvar:(CDOCInstanceVariable *)ivar;
{
    [ivar appendToString:self.resultString typeController:self.classDump.typeController];
    [self.resultString appendString:@"\n"];
}

- (void)visitProperty:(CDOCProperty *)property;
{
    CDType *parsedType = property.type;
    if (parsedType == nil) {
        if ([property.attributeString hasPrefix:@"T"]) {
            [self.resultString appendFormat:@"// Error parsing type for property %@:\n", property.name];
            [self.resultString appendFormat:@"// Property attributes: %@\n\n", property.attributeString];
        } else {
            [self.resultString appendFormat:@"// Error: Property attributes should begin with the type ('T') attribute, property name: %@\n", property.name];
            [self.resultString appendFormat:@"// Property attributes: %@\n\n", property.attributeString];
        }
    } else {
        [self _visitProperty:property parsedType:parsedType attributes:property.attributes];
    }
}

- (void)didVisitPropertiesOfClass:(CDOCClass *)aClass;
{
    if ([aClass.properties count] > 0)
        [self.resultString appendString:@"\n"];
}

- (void)willVisitPropertiesOfCategory:(CDOCCategory *)category;
{
    if ([category.properties count] > 0)
        [self.resultString appendString:@"\n"];
}

- (void)didVisitPropertiesOfCategory:(CDOCCategory *)category;
{
    if ([category.properties count] > 0/* && [aCategory hasMethods]*/)
        [self.resultString appendString:@"\n"];
}

- (void)willVisitPropertiesOfProtocol:(CDOCProtocol *)protocol;
{
    if ([protocol.properties count] > 0)
        [self.resultString appendString:@"\n"];
}

- (void)didVisitPropertiesOfProtocol:(CDOCProtocol *)protocol;
{
    if ([protocol.properties count] > 0 /*&& [aProtocol hasMethods]*/)
        [self.resultString appendString:@"\n"];
}

- (void)visitRemainingProperties:(CDVisitorPropertyState *)propertyState;
{
    NSArray *remaining = propertyState.remainingProperties;

    if ([remaining count] > 0) {
        [self.resultString appendString:@"\n"];
        [self.resultString appendFormat:@"// Remaining properties\n"];
        //CDLog(@"Warning: remaining undeclared property count: %u", [remaining count]);
        //CDLog(@"remaining: %@", remaining);
        for (CDOCProperty *property in remaining)
            [self visitProperty:property];
    }
}

#pragma mark -

@synthesize resultString = _resultString;

- (void)writeResultToStandardOutput;
{
    NSData *data = [self.resultString dataUsingEncoding:NSUTF8StringEncoding];
    [(NSFileHandle *)[NSFileHandle fileHandleWithStandardOutput] writeData:data];
}

- (void)_visitProperty:(CDOCProperty *)property parsedType:(CDType *)parsedType attributes:(NSArray *)attrs;
{
//    NSString *backingVar = nil;
//    BOOL isDynamic = NO;
//    
//    NSMutableArray *alist = [[NSMutableArray alloc] init];
//    NSMutableArray *unknownAttrs = [[NSMutableArray alloc] init];
//    
//    // objc_v2_encode_prop_attr() in gcc/objc/objc-act.c
//    
//    for (NSString *attr in attrs) {
//        if ([attr hasPrefix:@"T"]) {
//            CDLogVerbose(@"Warning: Property attribute 'T' should occur only occur at the beginning");
//        } else if ([attr hasPrefix:@"R"]) {
//            [alist addObject:@"readonly"];
//        } else if ([attr hasPrefix:@"C"]) {
//            [alist addObject:@"copy"];
//        } else if ([attr hasPrefix:@"&"]) {
//            [alist addObject:@"strong"];
//        } else if ([attr hasPrefix:@"G"]) {
//            [alist addObject:[NSString stringWithFormat:@"getter=%@", [attr substringFromIndex:1]]];
//        } else if ([attr hasPrefix:@"S"]) {
//            [alist addObject:[NSString stringWithFormat:@"setter=%@", [attr substringFromIndex:1]]];
//        } else if ([attr hasPrefix:@"V"]) {
//            backingVar = [attr substringFromIndex:1];
//        } else if ([attr hasPrefix:@"N"]) {
//            [alist addObject:@"nonatomic"];
//        } else if ([attr hasPrefix:@"W"]) {
//            // @property(assign) __weak NSObject *prop;
//            // Only appears with GC.
//            [alist addObject:@"weak"];
//        } else if ([attr hasPrefix:@"P"]) {
//            // @property(assign) __strong NSObject *prop;
//            // Only appears with GC.
//            // This is the default.
//        } else if ([attr hasPrefix:@"D"]) {
//            // Dynamic property.  Implementation supplied at runtime.
//            // @property int prop; // @dynamic prop;
//            isDynamic = YES;
//        } else {
//            CDLogVerbose(@"Warning: Unknown property attribute '%@'", attr);
//            [unknownAttrs addObject:attr];
//        }
//    }
//    
//    if (property.isClass) {
//        [alist addObject:@"class"];
//    }
    NSDictionary<CDOCPropertyAttributeType, NSNumber *> *propertyAttributeTypeWeights = self.classDump.configuration.propertyAttributeTypeWeights;
    NSArray<CDOCPropertyAttribute *> *propertyAttributes = nil;
    if (propertyAttributeTypeWeights) {
        propertyAttributes = [property.detailAttributes sortedArrayUsingComparator:^NSComparisonResult(CDOCPropertyAttribute *attribute1 , CDOCPropertyAttribute *attribute2) {
            CDOCPropertyAttributeType type1 = attribute1.type;
            CDOCPropertyAttributeType type2 = attribute2.type;
            NSNumber *weight1 = propertyAttributeTypeWeights[type1];
            NSNumber *weight2 = propertyAttributeTypeWeights[type2];
            return [weight1 compare:weight2];
        }];
    } else {
        propertyAttributes = property.detailAttributes;
    }
    
    NSArray<NSString *> *propertyAttributeStrings = [propertyAttributes map:^NSString * _Nonnull(CDOCPropertyAttribute * _Nonnull attribute) {
        if (attribute.value != nil) {
            return [NSString stringWithFormat:@"%@=%@", attribute.name, attribute.value];
        } else {
            return attribute.name;
        }
    }];
    if ([propertyAttributeStrings count] > 0) {
        [self.resultString appendFormat:@"@property (%@) ", [propertyAttributeStrings componentsJoinedByString:@", "]];
    } else {
        [self.resultString appendString:@"@property "];
    }
    
    NSString *formattedString = [self.classDump.typeController.propertyTypeFormatter formatVariable:property.name type:parsedType];
    [self.resultString appendFormat:@"%@;", formattedString];
    
    if (self.shouldAppendPropertyComments) {
        if (property.isDynamic) {
            [self.resultString appendFormat:@" // @dynamic %@;", property.name];
        } else if (property.ivar != nil) {
            if ([property.ivar isEqualToString:property.name]) {
                [self.resultString appendFormat:@" // @synthesize %@;", property.name];
            } else {
                [self.resultString appendFormat:@" // @synthesize %@=%@;", property.name, property.ivar];
            }
        }
    }
    
    [self.resultString appendString:@"\n"];
    if ([property.unknownAttributes count] > 0) {
        [self.resultString appendFormat:@"// Preceding property had unknown attributes: %@\n", [property.unknownAttributes componentsJoinedByString:@","]];
        if ([property.attributeString length] > 80) {
            [self.resultString appendFormat:@"// Original attribute string (following type): %@\n\n", property.attributeStringAfterType];
        } else {
            [self.resultString appendFormat:@"// Original attribute string: %@\n\n", property.attributeString];
        }
    }
}

@end
