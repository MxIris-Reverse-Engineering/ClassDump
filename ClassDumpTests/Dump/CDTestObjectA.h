#import <objc/NSObject.h>

@interface CDTestObjectA : NSObject

@property (nonatomic, readonly, class) id objectClassProperty;
@property (nonatomic, readonly, class) _Bool valueClassProperty;
@property (nonatomic, readonly, class) struct CDTestStructA structClassProperty;
@property (nonatomic, getter=isEnabled) _Bool enabled;
@property (nonatomic, setter=_setIntValue:) int _intValue;
@property (nonatomic, strong) id objectValue;
@property (nonatomic) _Bool boolValue;
@property (nonatomic, copy) CDUnknownBlockType blockValue;

+ (void)voidClassMethod;
- (void)voidInstanceMethod;

@end

