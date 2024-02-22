//
//  CDLCExportTRIEData.h
//  classdumpios
//
//  Created by kevinbradley on 6/26/22.
//

#import <Foundation/Foundation.h>
#import "CDLoadCommand.h"
NS_ASSUME_NONNULL_BEGIN

@interface CDLCExportTRIEData : CDLoadCommand
- (uint64_t)getExportedSymbolLocation:(NSString *)symbol;
@end

NS_ASSUME_NONNULL_END
