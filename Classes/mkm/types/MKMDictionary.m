//
//  MKMDictionary.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMDictionary.h"

@implementation MKMDictionary

- (instancetype)initWithJSONString:(const NSString *)jsonString {
    NSData *data = [jsonString data];
    NSDictionary *dict = [data jsonDictionary];
    self = [self initWithDictionary:dict];
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:dict];
    }
    return self;
}

/* designated initializer */
- (instancetype)init {
    if (self = [super init]) {
        _storeDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithObjects:(const id _Nonnull [_Nullable])objects
                        forKeys:(const id <NSCopying> _Nonnull [_Nullable])keys
                          count:(NSUInteger)cnt {
    if (self = [super init]) {
        _storeDictionary = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
    }
    return self;
}

/* designated initializer */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _storeDictionary = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    id dict = [[self class] allocWithZone:zone];
    dict = [dict initWithDictionary:_storeDictionary];
    return dict;
}

- (BOOL)isEqual:(id)object {
    return [_storeDictionary isEqualToDictionary:object];
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

- (NSEnumerator *)objectEnumerator {
    return [_storeDictionary objectEnumerator];
}

@end

@implementation MKMDictionary (Mutable)

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    if (self = [self init]) {
        _storeDictionary = [[NSMutableDictionary alloc] initWithCapacity:numItems];
    }
    return self;
}

- (id)mutableCopy {
    return [self copy];
}

- (void)removeObjectForKey:(const NSString *)aKey {
    [_storeDictionary removeObjectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(const NSString *)aKey {
    [_storeDictionary setObject:anObject forKey:aKey];
}

@end

@implementation NSDictionary (Binary)

- (BOOL)writeToBinaryFile:(NSString *)path {
    NSData *data;
    NSPropertyListFormat fmt = NSPropertyListBinaryFormat_v1_0;
    NSPropertyListWriteOptions opt = 0;
    NSError *err = nil;
    data = [NSPropertyListSerialization dataWithPropertyList:self
                                                      format:fmt
                                                     options:opt
                                                       error:&err];
    if (err) {
        NSAssert(false, @"serialize failed: %@", err);
        return NO;
    }
    return [data writeToFile:path atomically:YES];
}

@end
