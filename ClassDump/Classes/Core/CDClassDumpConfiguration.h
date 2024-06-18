//
//  CDClassDumpConfiguration.h
//  ClassDump
//
//  Created by JH on 2024/6/18.
//

#import <Foundation/Foundation.h>
#import <ClassDump/CDOCPropertyAttribute.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDClassDumpConfiguration : NSObject
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
@property BOOL stopAfterPreProcessor;
@property BOOL shallow;
@property (copy, nullable) NSRegularExpression *regularExpression;
@property (copy, nullable) NSArray<CDOCPropertyAttributeType> *sortedPropertyAttributeTypes;
@end

NS_ASSUME_NONNULL_END
