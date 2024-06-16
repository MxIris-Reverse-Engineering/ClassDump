//
//  CDLogger.m
//  ClassDump
//
//  Created by JH on 2024/5/31.
//

#import "CDLogger.h"
#import <OSLog/OSLog.h>

@interface CDLogger ()

@property (nonatomic, strong) os_log_t logger;

@end

@implementation CDLogger

+ (instancetype)sharedLogger {
    static id sharedLogger = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogger = [[CDLogger alloc] init];
    });
    
    return sharedLogger;
}

- (instancetype)init {
    if (self = [super init]) {
        _logger = os_log_create("com.JH.ClassDump", "com.JH.ClassDump");
        _logSystem = CDLogSystemNSLog;
    }
    return self;
}

- (void)logLevel:(CDLogLevel)level string:(NSString *)string {
    [self logLevel:level stringWithFormat:string, nil];
}

- (void)logLevel:(CDLogLevel)level stringWithFormat:(NSString *)fmt, ... {
    if (!self.isEnabled) {
        return;
    }
    va_list args;
    va_start(args, fmt);
    va_end(args);
    
    NSString *logContents = [[NSString alloc] initWithFormat:fmt arguments:args];
    
    switch (self.logSystem) {
        case CDLogSystemNSLog: {
            NSLog(@"%@", logContents);
        }
            break;
        case CDLogSystemOSLog: {
            switch (level) {
                case CDLogLevelVerbose:
                    if (self.isVerbose) {
                        os_log_debug(self.logger, "%{public}@", logContents);
                    }
                    break;
                case CDLogLevelInfo:
                    os_log_info(self.logger, "%{public}@", logContents);
                    break;
                case CDLogLevelDefault:
                    os_log(self.logger, "%{public}@", logContents);
                    break;
                case CDLogLevelWarning:
                    os_log_error(self.logger, "%{public}@", logContents);
                    break;
                case CDLogLevelError:
                    os_log_fault(self.logger, "%{public}@", logContents);
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

@end
