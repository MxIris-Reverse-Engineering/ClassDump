//
//  CDLogger.h
//  ClassDump
//
//  Created by JH on 2024/5/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CDLogLevel) {
    CDLogLevelVerbose,
    CDLogLevelInfo,
    CDLogLevelDefault,
    CDLogLevelWarning,
    CDLogLevelError,
};

typedef NS_ENUM(NSInteger, CDLogSystem) {
    CDLogSystemNSLog,
    CDLogSystemOSLog,
};

@interface CDLogger : NSObject

@property (assign, getter=isVerbose) BOOL verbose;
@property (assign, getter=isEnabled) BOOL enabled;
@property (assign) CDLogSystem logSystem;


+ (instancetype)sharedLogger;

- (void)logLevel:(CDLogLevel)level string:(NSString *)string;
- (void)logLevel:(CDLogLevel)level stringWithFormat:(NSString *)fmt, ...;

@end

NS_ASSUME_NONNULL_END
