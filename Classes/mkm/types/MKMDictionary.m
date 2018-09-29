//
//  MKMDictionary.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/27.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

@implementation MKMDictionary

- (instancetype)init {
    if (self = [super init]) {
        _storeDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    if (self = [super init]) {
        _storeDictionary = [otherDictionary mutableCopy];
    }
    return self;
}

- (id)copy {
    return [[[self class] alloc] initWithDictionary:_storeDictionary];
}

- (NSUInteger)count {
    return [_storeDictionary count];
}

- (id)objectForKey:(const NSString *)aKey {
    return [_storeDictionary objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {
    return [_storeDictionary keyEnumerator];
}

@end

@implementation MKMDictionary (Mutable)

- (id)mutableCopy {
    return [self copy];
}

- (void)removeObjectForKey:(const NSString *)aKey {
    [_storeDictionary removeObjectForKey:aKey];
}

- (void)setObject:(id)anObject
           forKey:(const NSString *)aKey {
    [_storeDictionary setObject:anObject forKey:aKey];
}

@end
