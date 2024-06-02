//
// Prefix header for all source files of the 'class-dump' target in the 'class-dump' project.
//

#ifdef __OBJC__

#import <Foundation/Foundation.h>
#import "CDLogger.h"

#define CAUGHT_EXCEPTION_LOG DLog(@"exception caught: %@", exception);

#define _CDLog(L, format, ...) [CDLogger.sharedLogger logLevel:L stringWithFormat:format, ## __VA_ARGS__];

#define DLog(format, ...)            _CDLog(CDLogLevelDefault, format, ## __VA_ARGS__);
#define VerboseLog(format, ...)      _CDLog(CDLogLevelVerbose, format, ## __VA_ARGS__);
#define InfoLog(format, ...)         _CDLog(CDLogLevelInfo,    format, ## __VA_ARGS__);

#define CDLog(format, ...)           _CDLog(CDLogLevelDefault, format, ## __VA_ARGS__);
#define CDLogVerbose(format, ...)    _CDLog(CDLogLevelVerbose, format, ## __VA_ARGS__);
#define CDLogInfo(format, ...)       _CDLog(CDLogLevelInfo,    format, ## __VA_ARGS__);
#define CDLogWarning(format, ...)    _CDLog(CDLogLevelWarning, format, ## __VA_ARGS__);
#define CDLogError(format, ...)      _CDLog(CDLogLevelError,   format, ## __VA_ARGS__);

#define OLog(a,b) DLog(@"%@: %016llx (%lu)", a, b, b)
#define OILog(a,b) InfoLog(@"%@: %016llx (%lu)", a, b, b)
#define ODLog(a,b) VerboseLog(@"%@: %016llx (%lu)", a, b, b)

#define ILOG_CMD        InfoLog(@"%s", __PRETTY_FUNCTION__)
#define VLOG_CMD        VerboseLog(@"%s", __PRETTY_FUNCTION__)
#define LOG_CMD         DLog(@"%s", __PRETTY_FUNCTION__)
#define _cmds __PRETTY_FUNCTION__

#endif
