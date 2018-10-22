//
//  DIMDictionary.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMDictionary.h"

@implementation DIMDictionary

/* designated initializer */
- (instancetype)init {
    self = [super init];
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSMutableDictionary *dict;
    dict = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    if (dict) {
        if (self = [self init]) {
            _storeDictionary = dict;
        }
    } else {
        self = nil;
    }
    return self;
}

- (instancetype)initWithObjects:(const id _Nonnull [_Nullable])objects
                        forKeys:(const id <NSCopying> _Nonnull [_Nullable])keys
                          count:(NSUInteger)cnt {
    if (self = [self init]) {
        _storeDictionary = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
    }
    return self;
}

@end
