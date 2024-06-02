#import <objc/NSObject.h>

@interface CDTestObjectA : NSObject
{
    _Bool _boolValue;	// 8 = 0x8
    id _objectValue;	// 16 = 0x10
}

+ (void)voidClassMethod;
+ (struct CDTestStructA)structClassProperty;
+ (_Bool)valueClassProperty;
+ (id)objectClassProperty;
- (void).cxx_destruct;
@property (strong, nonatomic) id objectValue;
@property (nonatomic) _Bool boolValue;
- (void)voidInstanceMethod;

// Remaining properties
@property (readonly, nonatomic, class) id objectClassProperty;
@property (readonly, nonatomic, class) struct CDTestStructA structClassProperty;
@property (readonly, nonatomic, class) _Bool valueClassProperty;

@end

