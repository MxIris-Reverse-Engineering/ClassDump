#ifdef __OBJC__

#import <Foundation/Foundation.h>
#import "CDLogger.h"

#define CAUGHT_EXCEPTION_LOG CDLog(@"exception caught: %@", exception);

#define _CDLog(L, format, ...) [CDLogger.sharedLogger logLevel:L stringWithFormat:format, ## __VA_ARGS__];

#define CDLog(format, ...)           _CDLog(CDLogLevelDefault, format, ## __VA_ARGS__);
#define CDLogVerbose(format, ...)    _CDLog(CDLogLevelVerbose, format, ## __VA_ARGS__);
#define CDLogInfo(format, ...)       _CDLog(CDLogLevelInfo,    format, ## __VA_ARGS__);
#define CDLogWarning(format, ...)    _CDLog(CDLogLevelWarning, format, ## __VA_ARGS__);
#define CDLogError(format, ...)      _CDLog(CDLogLevelError,   format, ## __VA_ARGS__);

#define CDLogInfo_HEX(a,b) CDLogInfo(@"%@: %016llx (%lu)", a, b, b)
#define CDLogVerbose_HEX(a,b) CDLogVerbose(@"%@: %016llx (%lu)", a, b, b)

#define CDLogInfo_CMD           CDLogInfo(@"%s", __PRETTY_FUNCTION__)
#define CDLogVerbose_CMD        CDLogVerbose(@"%s", __PRETTY_FUNCTION__)

#endif
