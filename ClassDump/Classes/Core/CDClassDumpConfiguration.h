//
//  CDClassDumpConfiguration.h
//  ClassDump
//
//  Created by JH on 2024/6/18.
//

#import <Foundation/Foundation.h>
#import <ClassDump/CDOCPropertyAttribute.h>
#import <ClassDump/CDFatArch.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CDProtocolFilenameFormatter <NSObject>

- (NSString *)stringForProtocolName:(NSString *)protocolName;

@end

@protocol CDCategoryFilenameFormatter <NSObject>

- (NSString *)stringForClassName:(NSString *)className categoryName:(NSString *)categoryName;

@end

@interface CDClassDumpConfiguration : NSObject <NSCopying, NSSecureCoding>

@property BOOL shouldProcessRecursively;
@property BOOL shouldSortClasses;
@property BOOL shouldSortClassesByInheritance;
@property BOOL shouldSortMethods;
@property BOOL shouldShowIvarOffsets;
@property BOOL shouldShowMethodAddresses;
@property BOOL shouldShowHeader;
@property BOOL shouldStripOverrides;
@property BOOL shouldStripSynthesized;
@property BOOL shouldStripCtor;
@property BOOL shouldStripDtor;
@property BOOL shouldUseBOOLTypedef;
@property BOOL shouldUseNSIntegerTypedef;
@property BOOL shouldUseNSUIntegerTypedef;
/// replace @c retain to @c strong
@property BOOL shouldUseStrongPropertyAttribute;
@property BOOL shouldGenerateEmptyImplementationFile;

//@property (copy, nullable) NSRegularExpression *regularExpression;
@property (copy) NSArray<CDOCPropertyAttributeType> *sortedPropertyAttributeTypes;

@property (copy, readonly) NSDictionary<CDOCPropertyAttributeType, NSNumber *> *propertyAttributeTypeWeights;

@property (copy, nullable) NSString *preferredStructureFilename;
@property (weak, nullable) id<CDProtocolFilenameFormatter> protocolFilenameFormatter;
@property (weak, nullable) id<CDCategoryFilenameFormatter> categoryFilenameFormatter;

- (BOOL)shouldShowName:(NSString *)name;
- (void)applyConfiguration:(CDClassDumpConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
