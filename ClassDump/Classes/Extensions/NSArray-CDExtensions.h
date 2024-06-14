// -*- mode: ObjC -*-

//  This file is part of class-dump, a utility for examining the Objective-C segment of Mach-O files.
//  Copyright (C) 1997-2019 Steve Nygard.

#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (CDExtensions)

- (NSArray<ObjectType> *)reversedArray;

@end

@interface NSArray<ObjectType> (CDTopoSort)

- (NSArray<ObjectType> *)topologicallySortedArray;

@end

@interface NSMutableArray<ObjectType> (CDTopoSort)

- (void)sortTopologically;

@end
