//
//  CDClassDumpConfiguration.m
//  ClassDump
//
//  Created by JH on 2024/6/18.
//

#import "CDClassDumpConfiguration.h"

@implementation CDClassDumpConfiguration

@synthesize sortedPropertyAttributeTypes = _sortedPropertyAttributeTypes;

- (instancetype)init {
    self = [super init];
    if (self) {
        _targetArch.cputype = CPU_TYPE_ANY;
        _targetArch.cpusubtype = 0;
    }
    return self;
}


- (BOOL)shouldShowName:(NSString *)name;
{
    if (self.regularExpression != nil) {
        NSTextCheckingResult *firstMatch = [self.regularExpression firstMatchInString:name options:(NSMatchingOptions)0 range:NSMakeRange(0, [name length])];
        return firstMatch != nil;
    }
    
    return YES;
}

- (void)setSortedPropertyAttributeTypes:(NSArray<CDOCPropertyAttributeType> *)sortedPropertyAttributeTypes {
    @synchronized (self) {
        _sortedPropertyAttributeTypes = sortedPropertyAttributeTypes;
        if (sortedPropertyAttributeTypes) {
            BOOL containsAllPropertyAttributeTypes = [sortedPropertyAttributeTypes containsObject:CDOCPropertyAttributeTypeClass] &&
                                                     [sortedPropertyAttributeTypes containsObject:CDOCPropertyAttributeTypeGetter] &&
                                                     [sortedPropertyAttributeTypes containsObject:CDOCPropertyAttributeTypeSetter] &&
                                                     [sortedPropertyAttributeTypes containsObject:CDOCPropertyAttributeTypeReadwrite] &&
                                                     [sortedPropertyAttributeTypes containsObject:CDOCPropertyAttributeTypeReference] &&
                                                     [sortedPropertyAttributeTypes containsObject:CDOCPropertyAttributeTypeThreadSafe];
            NSAssert(containsAllPropertyAttributeTypes, @"All attribute types must be included.");
            NSMutableDictionary<CDOCPropertyAttributeType, NSNumber *> *propertyAttributeTypeWeights = [NSMutableDictionary dictionary];
            propertyAttributeTypeWeights[CDOCPropertyAttributeTypeClass] = @([sortedPropertyAttributeTypes indexOfObject:CDOCPropertyAttributeTypeClass]);
            propertyAttributeTypeWeights[CDOCPropertyAttributeTypeSetter] = @([sortedPropertyAttributeTypes indexOfObject:CDOCPropertyAttributeTypeSetter]);
            propertyAttributeTypeWeights[CDOCPropertyAttributeTypeGetter] = @([sortedPropertyAttributeTypes indexOfObject:CDOCPropertyAttributeTypeGetter]);
            propertyAttributeTypeWeights[CDOCPropertyAttributeTypeReadwrite] = @([sortedPropertyAttributeTypes indexOfObject:CDOCPropertyAttributeTypeReadwrite]);
            propertyAttributeTypeWeights[CDOCPropertyAttributeTypeReference] = @([sortedPropertyAttributeTypes indexOfObject:CDOCPropertyAttributeTypeReference]);
            propertyAttributeTypeWeights[CDOCPropertyAttributeTypeThreadSafe] = @([sortedPropertyAttributeTypes indexOfObject:CDOCPropertyAttributeTypeThreadSafe]);
            _propertyAttributeTypeWeights = propertyAttributeTypeWeights;
        }
    }
}

- (NSArray<CDOCPropertyAttributeType> *)sortedPropertyAttributeTypes {
    @synchronized (self) {
        return _sortedPropertyAttributeTypes;
    }
}

- (void)applyConfiguration:(CDClassDumpConfiguration *)configuration {
    self.shouldProcessRecursively = configuration.shouldProcessRecursively;
    self.shouldSortClasses = configuration.shouldSortClasses;
    self.shouldSortClassesByInheritance = configuration.shouldSortClassesByInheritance;
    self.shouldSortMethods = configuration.shouldSortMethods;
    self.shouldShowIvarOffsets = configuration.shouldShowIvarOffsets;
    self.shouldShowMethodAddresses = configuration.shouldShowMethodAddresses;
    self.shouldShowHeader = configuration.shouldShowHeader;
    self.shouldStripOverrides = configuration.shouldStripOverrides;
    self.shouldStripSynthesized = configuration.shouldStripSynthesized;
    self.shouldStripCtor = configuration.shouldStripCtor;
    self.shouldStripDtor = configuration.shouldStripDtor;
    self.stopAfterPreProcessor = configuration.stopAfterPreProcessor;
    self.shallow = configuration.shallow;
    self.shouldUseBOOLTypedef = configuration.shouldUseBOOLTypedef;
    self.shouldUseNSIntegerTypedef = configuration.shouldUseNSIntegerTypedef;
    self.shouldUseNSUIntegerTypedef = configuration.shouldUseNSUIntegerTypedef;
    self.targetArch = configuration.targetArch;
    self.sdkRoot = configuration.sdkRoot;
    self.regularExpression = configuration.regularExpression;
    self.sortedPropertyAttributeTypes = configuration.sortedPropertyAttributeTypes;
}

@end
