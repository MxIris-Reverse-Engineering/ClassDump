#import <Foundation/Foundation.h>

@interface NSData (Filp)
- (NSString *)stringFromHexData;
- (NSData *)byteFlipped;
+ (NSData *)dataFromStringHex:(NSString *)command;
- (NSData *)reverse;
- (NSString *)decimalString;
+ (NSData *)littleEndianHexFromInt:(NSUInteger)inputNumber;
@end


