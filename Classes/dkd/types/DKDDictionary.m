//
//  DKDDictionary.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDDictionary.h"

@implementation DKDDictionary

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    return self;
}

- (instancetype)init {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    self = [self initWithDictionary:dict];
    return self;
}

- (instancetype)initWithObjects:(const id _Nonnull [_Nullable])objects
                        forKeys:(const id <NSCopying> _Nonnull [_Nullable])keys
                          count:(NSUInteger)cnt {
    NSMutableDictionary *dict;
    dict = [[NSMutableDictionary alloc] initWithObjects:objects
                                                forKeys:keys
                                                  count:cnt];
    self = [self initWithDictionary:dict];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSMutableDictionary *dict;
    dict = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    self = [self initWithDictionary:dict];
    return self;
}

@end
