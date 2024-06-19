//
//  CDTestObjectA.h
//  TestFramework
//
//  Created by JH on 2024/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

struct CDTestStructA {
    NSInteger integerMember;
};

@interface CDTestObjectA : NSObject
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, setter=_setIntValue:) int _intValue;
@property (nonatomic, strong) id objectValue;
@property (nonatomic) BOOL boolValue;
@property (nonatomic, class, strong, readonly) id objectClassProperty;
@property (nonatomic, class, readonly) BOOL valueClassProperty;
@property (nonatomic, class, readonly) struct CDTestStructA structClassProperty;
@property (nonatomic, copy) NSString *(^blockValue)(BOOL, NSInteger);
+ (void)voidClassMethod;
- (void)voidInstanceMethod;

@end

NS_ASSUME_NONNULL_END
