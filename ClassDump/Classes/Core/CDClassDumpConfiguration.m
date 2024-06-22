//
//  CDClassDumpConfiguration.m
//  ClassDump
//
//  Created by JH on 2024/6/18.
//

#import "CDClassDumpConfiguration.h"

@implementation CDClassDumpConfiguration

@synthesize sortedPropertyAttributeTypes = _sortedPropertyAttributeTypes;

- (void)commonInit {
    if (!self.sortedPropertyAttributeTypes) {
        self.sortedPropertyAttributeTypes = @[
            CDOCPropertyAttributeTypeThreadSafe,
            CDOCPropertyAttributeTypeReference,
            CDOCPropertyAttributeTypeReadwrite,
            CDOCPropertyAttributeTypeSetter,
            CDOCPropertyAttributeTypeGetter,
            CDOCPropertyAttributeTypeClass,
        ];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        
        self.shouldProcessRecursively = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldProcessRecursively))];
        self.shouldSortClasses = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldSortClasses))];
        self.shouldSortClassesByInheritance = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldSortClassesByInheritance))];
        self.shouldSortMethods = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldSortMethods))];
        self.shouldShowIvarOffsets = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldShowIvarOffsets))];
        self.shouldShowMethodAddresses = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldShowMethodAddresses))];
        self.shouldShowHeader = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldShowHeader))];
        self.shouldStripOverrides = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldStripOverrides))];
        self.shouldStripSynthesized = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldStripSynthesized))];
        self.shouldStripCtor = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldStripCtor))];
        self.shouldStripDtor = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldStripDtor))];
        self.shouldUseBOOLTypedef = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldUseBOOLTypedef))];
        self.shouldUseNSIntegerTypedef = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldUseNSIntegerTypedef))];
        self.shouldUseNSUIntegerTypedef = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldUseNSUIntegerTypedef))];
        self.shouldUseStrongPropertyAttribute = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldUseStrongPropertyAttribute))];
        self.shouldGenerateEmptyImplementationFile = [coder decodeBoolForKey:NSStringFromSelector(@selector(shouldGenerateEmptyImplementationFile))];
        self.sortedPropertyAttributeTypes = [coder decodeObjectOfClasses:[NSSet setWithArray:@[[NSArray class], [NSString class]]] forKey:NSStringFromSelector(@selector(sortedPropertyAttributeTypes))];
        self.preferredStructureFilename = [coder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(preferredStructureFilename))];
        [self commonInit];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.shouldProcessRecursively forKey:NSStringFromSelector(@selector(shouldProcessRecursively))];
    [coder encodeBool:self.shouldSortClasses forKey:NSStringFromSelector(@selector(shouldSortClasses))];
    [coder encodeBool:self.shouldSortClassesByInheritance forKey:NSStringFromSelector(@selector(shouldSortClassesByInheritance))];
    [coder encodeBool:self.shouldSortMethods forKey:NSStringFromSelector(@selector(shouldSortMethods))];
    [coder encodeBool:self.shouldShowIvarOffsets forKey:NSStringFromSelector(@selector(shouldShowIvarOffsets))];
    [coder encodeBool:self.shouldShowMethodAddresses forKey:NSStringFromSelector(@selector(shouldShowMethodAddresses))];
    [coder encodeBool:self.shouldShowHeader forKey:NSStringFromSelector(@selector(shouldShowHeader))];
    [coder encodeBool:self.shouldStripOverrides forKey:NSStringFromSelector(@selector(shouldStripOverrides))];
    [coder encodeBool:self.shouldStripSynthesized forKey:NSStringFromSelector(@selector(shouldStripSynthesized))];
    [coder encodeBool:self.shouldStripCtor forKey:NSStringFromSelector(@selector(shouldStripCtor))];
    [coder encodeBool:self.shouldStripDtor forKey:NSStringFromSelector(@selector(shouldStripDtor))];
    [coder encodeBool:self.shouldUseBOOLTypedef forKey:NSStringFromSelector(@selector(shouldUseBOOLTypedef))];
    [coder encodeBool:self.shouldUseNSIntegerTypedef forKey:NSStringFromSelector(@selector(shouldUseNSIntegerTypedef))];
    [coder encodeBool:self.shouldUseNSUIntegerTypedef forKey:NSStringFromSelector(@selector(shouldUseNSUIntegerTypedef))];
    [coder encodeBool:self.shouldUseStrongPropertyAttribute forKey:NSStringFromSelector(@selector(shouldUseStrongPropertyAttribute))];
    [coder encodeBool:self.shouldGenerateEmptyImplementationFile forKey:NSStringFromSelector(@selector(shouldGenerateEmptyImplementationFile))];
    [coder encodeObject:self.sortedPropertyAttributeTypes forKey:NSStringFromSelector(@selector(sortedPropertyAttributeTypes))];
    [coder encodeObject:self.preferredStructureFilename forKey:NSStringFromSelector(@selector(preferredStructureFilename))];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)shouldShowName:(NSString *)name;
{
//    if (self.regularExpression != nil) {
//        NSTextCheckingResult *firstMatch = [self.regularExpression firstMatchInString:name options:(NSMatchingOptions)0 range:NSMakeRange(0, [name length])];
//        return firstMatch != nil;
//    }
    
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
//    self.stopAfterPreProcessor = configuration.stopAfterPreProcessor;
//    self.shallow = configuration.shallow;
    self.shouldUseBOOLTypedef = configuration.shouldUseBOOLTypedef;
    self.shouldUseNSIntegerTypedef = configuration.shouldUseNSIntegerTypedef;
    self.shouldUseNSUIntegerTypedef = configuration.shouldUseNSUIntegerTypedef;
    self.shouldUseStrongPropertyAttribute = configuration.shouldUseStrongPropertyAttribute;
//    self.targetArch = configuration.targetArch;
//    self.sdkRoot = configuration.sdkRoot;
//    self.regularExpression = configuration.regularExpression;
    self.sortedPropertyAttributeTypes = configuration.sortedPropertyAttributeTypes;
    self.shouldGenerateEmptyImplementationFile = configuration.shouldGenerateEmptyImplementationFile;
    self.preferredStructureFilename = configuration.preferredStructureFilename;
    self.protocolFilenameFormatter = configuration.protocolFilenameFormatter;
    self.categoryFilenameFormatter = configuration.categoryFilenameFormatter;
}


- (id)copyWithZone:(NSZone *)zone {
    CDClassDumpConfiguration *configuration = [CDClassDumpConfiguration new];
    [configuration applyConfiguration:self];
    return configuration;
}

@end
