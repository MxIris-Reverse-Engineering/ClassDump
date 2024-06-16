//
//  NSArray+Functional.m
//  FormMaster
//
//  Created by JH on 2023/10/24.
//  Copyright © 2023 FormMaster. All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray (Functional)



- (NSArray *)map:(id (^)(id obj))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    for (id obj in self) {
        [result addObject:block(obj)];
    }
    return result.copy;
}

- (NSArray *)flatMap:(NSArray * (^)(id obj))block {
    NSMutableArray *result = [NSMutableArray array];
    for (id obj in self) {
        NSArray *subArray = block(obj);
        [result addObjectsFromArray:subArray];
    }
    return result.copy;
}

- (NSArray *)compactMap:(id (^)(id obj))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    for (id obj in self) {
        id mappedObj = block(obj);
        if (mappedObj) {
            [result addObject:mappedObj];
        }
    }
    return result.copy;
}

- (NSArray *)filter:(BOOL (^)(id obj))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    for (id obj in self) {
        if (block(obj)) {
            [result addObject:obj];
        }
    }
    return result.copy;
}

- (BOOL)allSatisfy:(BOOL (^)(id obj))block {
    for (id obj in self) {
        if (!block(obj)) {
            return NO;
        }
    }
    return YES;
}

- (id)reduceWithInitial:(id)initial block:(id (^)(id accumulator, id obj))block {
    id accumulator = initial;
    for (id obj in self) {
        accumulator = block(accumulator, obj);
    }
    return accumulator;
}

@end
