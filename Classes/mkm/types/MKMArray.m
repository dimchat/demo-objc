//
//  MKMArray.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/27.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMArray.h"

@implementation MKMArray

- (instancetype)init {
    if (self = [super init]) {
        _storeArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        _storeArray = [array mutableCopy];
    }
    return self;
}

- (id)copy {
    return [[[self class] alloc] initWithArray:_storeArray];
}

- (NSUInteger)count {
    return [_storeArray count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [_storeArray objectAtIndex:index];
}

- (NSEnumerator *)objectEnumerator {
    return [_storeArray objectEnumerator];
}

@end

@implementation MKMArray (Mutable)

- (id)mutableCopy {
    return [self copy];
}

- (void)addObject:(id)anObject {
    [_storeArray addObject:anObject];
}

- (void)insertObject:(id)anObject
             atIndex:(NSUInteger)index {
    [_storeArray insertObject:anObject atIndex:index];
}

- (void)removeLastObject {
    [_storeArray removeLastObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [_storeArray removeObjectAtIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index
                  withObject:(id)anObject {
    [_storeArray replaceObjectAtIndex:index withObject:anObject];
}

@end
