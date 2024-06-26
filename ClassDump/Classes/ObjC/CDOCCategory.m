// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <ClassDump/CDOCCategory.h>

#import <ClassDump/CDClassDump.h>
#import <ClassDump/CDOCMethod.h>
#import <ClassDump/CDVisitor.h>
#import <ClassDump/CDVisitorPropertyState.h>
#import <ClassDump/CDOCClass.h>
#import <ClassDump/CDOCClassReference.h>
#import <ClassDump/ClassDumpUtils.h>
@implementation CDOCCategory

#pragma mark - Superclass overrides

- (NSString *)sortableName;
{
    return [NSString stringWithFormat:@"%@ (%@)", self.className, self.name];
}

#pragma mark -

- (NSString *)className
{
    return [_classRef className];
}

- (NSString *)methodSearchContext;
{
    NSMutableString *resultString = [NSMutableString string];

    [resultString appendFormat:@"@interface %@ (%@)", self.className, self.name];

    if ([self.protocols count] > 0)
        [resultString appendFormat:@" <%@>", self.protocolsString];

    return resultString;
}

- (void)recursivelyVisit:(CDVisitor *)visitor;
{
    if ([visitor.classDump.typeController shouldShowName:self.name]) {
        CDVisitorPropertyState *propertyState = [[CDVisitorPropertyState alloc] initWithProperties:self.properties];
        
        [visitor willVisitCategory:self];
        
        [visitor willVisitPropertiesOfCategory:self];
        [self visitProperties:visitor];
        [visitor didVisitPropertiesOfCategory:self];
        
        [self visitMethods:visitor propertyState:propertyState];
        // This can happen when... the accessors are implemented on the main class.  Odd case, but we should still emit the remaining properties.
        // Should mostly be dynamic properties
//        [visitor visitRemainingProperties:propertyState];
        [visitor didVisitCategory:self];
    }
}

#pragma mark - CDTopologicalSort protocol

- (NSString *)identifier;
{
    return self.sortableName;
}

- (NSArray *)dependancies;
{
    if (self.className == nil)
        return @[];

    return @[self.className];
}

@end
