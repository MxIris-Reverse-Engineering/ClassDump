// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDOCClass.h>
#import <ClassDump/CDOCProperty.h>
#import <ClassDump/CDClassDump.h>
#import <ClassDump/CDOCInstanceVariable.h>
#import <ClassDump/CDOCMethod.h>
#import <ClassDump/CDType.h>
#import <ClassDump/CDTypeController.h>
#import <ClassDump/CDTypeParser.h>
#import <ClassDump/CDVisitor.h>
#import <ClassDump/CDVisitorPropertyState.h>
#import <ClassDump/CDOCClassReference.h>
#import <ClassDump/ClassDumpUtils.h>
#import <ClassDump/CDClassDumpConfiguration.h>

@implementation CDOCClass {
    
    NSMutableOrderedSet<NSString *> *_instancePropertySynthesizedIvarNames;
    NSMutableSet *_classPropertyIgnoreNames;
    NSMutableSet *_instancePropertyIgnoreNames;
    NSMutableSet *_classMethodIgnoreNames;
    NSMutableSet *_instanceMethodIgnoreNames;
}

- (instancetype)init;
{
    if ((self = [super init])) {
        _isExported = YES;
        _instancePropertySynthesizedIvarNames = [NSMutableOrderedSet orderedSet];
        _classPropertyIgnoreNames = [NSMutableSet set];
        _instancePropertyIgnoreNames = [NSMutableSet set];
        _classMethodIgnoreNames = [NSMutableSet set];
        _instanceMethodIgnoreNames = [NSMutableSet set];
    }

    return self;
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"%@, exported: %@", [super description], self.isExported ? @"YES" : @"NO"];
}

#pragma mark -

- (NSString *)superClassName;
{
    return [_superClassRef className];
}

- (void)registerTypesWithObject:(CDTypeController *)typeController phase:(NSUInteger)phase;
{
    [super registerTypesWithObject:typeController phase:phase];

    for (CDOCInstanceVariable *instanceVariable in self.instanceVariables) {
        [instanceVariable.type phase:phase registerTypesWithObject:typeController usedInMethod:NO];
    }
}

- (NSString *)methodSearchContext;
{
    NSMutableString *resultString = [NSMutableString string];

    [resultString appendFormat:@"@interface %@", self.name];
    if (self.superClassName != nil)
        [resultString appendFormat:@" : %@", self.superClassName];

    if ([self.protocols count] > 0)
        [resultString appendFormat:@" <%@>", self.protocolsString];

    return resultString;
}

- (void)recursivelyVisit:(CDVisitor *)visitor;
{
    if ([visitor.classDump.typeController shouldShowName:self.name]) {
        CDVisitorPropertyState *propertyState = [[CDVisitorPropertyState alloc] initWithProperties:self.properties];
        
        [visitor willVisitClass:self];
        if (visitor.classDump.configuration.shouldStripOverrides) {
            [self searchOverridePropertiesAndMethods];
        }
        if (self.instanceVariables.count - self.instancePropertySynthesizedIvarNames.count) {
            [visitor willVisitIvarsOfClass:self];
            for (CDOCInstanceVariable *instanceVariable in self.instanceVariables) {
                if (visitor.classDump.configuration.shouldStripSynthesized && [self.instancePropertySynthesizedIvarNames containsObject:instanceVariable.name]) {
                    continue;
                }
                [visitor visitIvar:instanceVariable];
            }
            [visitor didVisitIvarsOfClass:self];
        }
        
        [visitor willVisitPropertiesOfClass:self];
        [self visitProperties:visitor];
        [visitor didVisitPropertiesOfClass:self];
        
        [self visitMethods:visitor propertyState:propertyState];
        // Should mostly be dynamic properties
//        [visitor visitRemainingProperties:propertyState];
        [visitor didVisitClass:self];
    }
}

- (void)searchOverridePropertiesAndMethods {
    CDOCClass *superClassObject = self.superClassRef.classObject;
    while (superClassObject != nil) {
        for (CDOCProperty *property in superClassObject.properties) {
            if (property.isClass) {
                if ([_classPropertyIgnoreNames containsObject:property.name]) {
                    continue;
                }
                [_classPropertyIgnoreNames addObject:property.name];
            } else {
                if ([_instancePropertyIgnoreNames containsObject:property.name]) {
                    continue;
                }
                [_instancePropertyIgnoreNames addObject:property.name];
            }
        }
        
        for (CDOCMethod *classMethod in superClassObject.classMethods) {
            if ([_classMethodIgnoreNames containsObject:classMethod.name]) {
                continue;
            }
            [_classMethodIgnoreNames addObject:classMethod.name];
        }
        
        for (CDOCMethod *instanceMethod in superClassObject.instanceMethods) {
            if ([_instanceMethodIgnoreNames containsObject:instanceMethod.name]) {
                continue;
            }
            [_instanceMethodIgnoreNames addObject:instanceMethod.name];
        }
        
        superClassObject = superClassObject.superClassRef.classObject;
    }
}

- (BOOL)shouldVisitProperty:(CDOCProperty *)property {
    if (property.isClass) {
        return ![_classPropertyIgnoreNames containsObject:property.name];
    } else {
        return ![_instancePropertyIgnoreNames containsObject:property.name];
    }
}

- (BOOL)shouldVisitClassMethod:(CDOCMethod *)method {
    return ![_classMethodIgnoreNames containsObject:method.name];
}

- (BOOL)shouldVisitInstanceMethod:(CDOCMethod *)method {
    return ![_instanceMethodIgnoreNames containsObject:method.name];
}

- (void)addProperty:(CDOCProperty *)property {
    [super addProperty:property];
    
    if (!property.isClass && property.ivar) {
        [_instancePropertySynthesizedIvarNames addObject:property.ivar];
    }
}

#pragma mark - CDTopologicalSort protocol

- (NSString *)identifier;
{
    return self.name;
}

- (NSArray *)dependancies;
{
    if (self.superClassName == nil)
        return @[];

    return @[self.superClassName];
}

@end
