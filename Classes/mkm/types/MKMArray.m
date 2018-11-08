//
//  MKMArray.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMArray.h"

@implementation MKMArray

- (instancetype)initWithJSONString:(const NSString *)jsonString {
    NSData *data = [jsonString data];
    NSArray *array = [data jsonArray];
    self = [self initWithArray:array];
    return self;
}

/* designated initializer */
- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        _storeArray = [[NSMutableArray alloc] initWithArray:array];
    }
    return self;
}

/* designated initializer */
- (instancetype)init {
    if (self = [super init]) {
        _storeArray = [[NSMutableArray alloc] init];
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithObjects:(const id _Nonnull [_Nullable])objects count:(NSUInteger)cnt {
    if (self = [super init]) {
        _storeArray = [[NSMutableArray alloc] initWithObjects:objects count:cnt];
    }
    return self;
}

/* designated initializer */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _storeArray = [[NSMutableArray alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    id array = [[self class] allocWithZone:zone];
    array = [array initWithArray:_storeArray];
    return array;
}

- (BOOL)isEqual:(id)object {
    return [_storeArray isEqualToArray:object];
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

- (NSEnumerator *)reverseObjectEnumerator {
    return [_storeArray reverseObjectEnumerator];
}

@end

@implementation MKMArray (Mutable)

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    if (self = [self init]) {
        _storeArray = [[NSMutableArray alloc] initWithCapacity:numItems];
    }
    return self;
}

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
