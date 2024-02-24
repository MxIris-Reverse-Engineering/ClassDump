//
//  classdump.h
//  classdump
//
//  Created by Kevin Bradley on 6/21/22.
//

#import <Foundation/Foundation.h>

@class CDClassDump;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(ClassDumpManager)
@interface CDClassDumpManager : NSObject

@property (nonatomic, strong, class, readonly) CDClassDumpManager *sharedManager NS_SWIFT_NAME(shared);
@property (assign) BOOL verbose;
- (NSInteger)performClassDumpOnFile:(NSString *)file withEntitlements:(BOOL)dumpEnt toFolder:(NSString *)outputPath;
- (NSInteger)performClassDumpOnFile:(NSString *)file toFolder:(NSString *)outputPath;
- (CDClassDump *)classDumpInstanceFromFile:(NSString *)file;
- (NSDictionary *)getFileEntitlements:(NSString *)file;

@end

NS_ASSUME_NONNULL_END
