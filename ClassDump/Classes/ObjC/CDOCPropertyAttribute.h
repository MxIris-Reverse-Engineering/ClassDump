//
//  CDPropertyAttribute.h
//  ClassDumpRuntime
//
//  Created by Leptos on 1/6/23.
//  Copyright © 2023 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_HEADER_AUDIT_BEGIN(nullability)

typedef NSString * CDOCPropertyAttributeType NS_TYPED_ENUM;

extern CDOCPropertyAttributeType const CDOCPropertyAttributeTypeThreadSafe; ///  @c nonatomic / @c atomic
extern CDOCPropertyAttributeType const CDOCPropertyAttributeTypeReference; /// @c retain / @c strong / @c weak / @c unsafe_unretain / @c copy
extern CDOCPropertyAttributeType const CDOCPropertyAttributeTypeReadwrite; /// @c readonly / @c readwrite
extern CDOCPropertyAttributeType const CDOCPropertyAttributeTypeGetter; /// @c getter
extern CDOCPropertyAttributeType const CDOCPropertyAttributeTypeSetter; /// @c setter
extern CDOCPropertyAttributeType const CDOCPropertyAttributeTypeClass; /// @c class
//extern CDOCPropertyAttributeType const CDOCPropertyAttributeTypeNullability; /// @c nullable / @c nonnull

@interface CDOCPropertyAttribute : NSObject
/// The name of a property attribute, e.g. @c strong, @c nonatomic, @c getter
@property (strong, nonatomic, readonly) NSString *name;
/// The value of a property attribute, e.g. the method name for @c getter= or @c setter=
@property (strong, nonatomic, readonly, nullable) NSString *value;

@property (strong, nonatomic, readonly) CDOCPropertyAttributeType type;

- (instancetype)initWithName:(NSString *)name value:(nullable NSString *)value type:(CDOCPropertyAttributeType)type;
+ (instancetype)attributeWithName:(NSString *)name value:(nullable NSString *)value type:(CDOCPropertyAttributeType)type;

@end

NS_HEADER_AUDIT_END(nullability)
