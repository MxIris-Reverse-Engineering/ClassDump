//
//  CDPropertyAttribute.m
//  ClassDumpRuntime
//
//  Created by Leptos on 1/6/23.
//  Copyright © 2023 Leptos. All rights reserved.
//

#import "CDOCPropertyAttribute.h"

CDOCPropertyAttributeType const CDOCPropertyAttributeTypeThreadSafe  = @"CDOCPropertyAttributeTypeThreadSafe"; /// @c nonatomic / @c atomic
CDOCPropertyAttributeType const CDOCPropertyAttributeTypeReference   = @"CDOCPropertyAttributeTypeReference"; /// @c retain / @c strong / @c weak / @c unsafe_unretain
CDOCPropertyAttributeType const CDOCPropertyAttributeTypeReadwrite   = @"CDOCPropertyAttributeTypeReadwrite"; /// @c readonly / @c readwrite
CDOCPropertyAttributeType const CDOCPropertyAttributeTypeGetter      = @"CDOCPropertyAttributeTypeGetter"; /// @c getter
CDOCPropertyAttributeType const CDOCPropertyAttributeTypeSetter      = @"CDOCPropertyAttributeTypeSetter"; /// @c setter
CDOCPropertyAttributeType const CDOCPropertyAttributeTypeClass       = @"CDOCPropertyAttributeTypeClass"; /// @c class
//CDOCPropertyAttributeType const CDOCPropertyAttributeTypeNullability = @"CDOCPropertyAttributeTypeNullability"; /// @c nullable / @c nonnull

@implementation CDOCPropertyAttribute

+ (instancetype)attributeWithName:(NSString *)name value:(NSString *)value type:(nonnull CDOCPropertyAttributeType)type {
    return [[self alloc] initWithName:name value:value type:type];
}

- (instancetype)initWithName:(NSString *)name value:(NSString *)value type:(nonnull CDOCPropertyAttributeType)type {
    if (self = [self init]) {
        _name = name;
        _value = value;
        _type = type;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        __typeof(self) casted = (__typeof(casted))object;
        return (self.name == casted.name || [self.name isEqual:casted.name]) &&
        (self.value == casted.value || [self.value isEqual:casted.value]);
    }
    return NO;
}

- (NSString *)description {
    NSString *name = self.name;
    NSString *value = self.value;
    if (value != nil) {
        return [[name stringByAppendingString:@"="] stringByAppendingString:value];
    }
    return name;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p> {name: '%@', value: '%@'}",
            [self class], self, self.name, self.value];
}

@end
