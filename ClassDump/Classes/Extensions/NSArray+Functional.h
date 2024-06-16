//
//  NSArray+Functional.h
//  FormMaster
//
//  Created by JH on 2023/10/24.
//  Copyright © 2023 FormMaster. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (Functional)



- (NSArray *)map:(id (^)(ObjectType obj))block;
- (NSArray *)flatMap:(NSArray * (^)(ObjectType obj))block;
- (NSArray *)compactMap:(id _Nullable(^)(ObjectType obj))block;
- (NSArray<ObjectType> *)filter:(BOOL (^)(ObjectType obj))block;
- (BOOL)allSatisfy:(BOOL (^)(ObjectType obj))block;
- (id)reduceWithInitial:(id)initial block:(id (^)(id accumulator, ObjectType obj))block;

@end

NS_ASSUME_NONNULL_END
