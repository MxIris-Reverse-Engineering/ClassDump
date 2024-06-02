//
//  CDTestObjectA.m
//  TestFramework
//
//  Created by JH on 2024/6/1.
//

#import "CDTestObjectA.h"

@implementation CDTestObjectA

@synthesize boolValue = _boolValue;

+ (id)objectClassProperty {
    return nil;
}

+ (BOOL)valueClassProperty {
    return NO;
}

+ (struct CDTestStructA)structClassProperty {
    struct CDTestStructA s = {
        .integerMember = 0
    };

    return s;
}

- (void)voidInstanceMethod {
}

+ (void)voidClassMethod {
}

- (void)setBoolValue:(BOOL)boolValue {
    _boolValue = boolValue;
}

- (BOOL)boolValue {
    return _boolValue;
}

@end
