//
//  MKMString.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMString.h"

@implementation MKMString

/* designated initializer */
- (instancetype)initWithString:(NSString *)aString {
    if (self = [super init]) {
        _storeString = [[NSString alloc] initWithString:aString];
    }
    return self;
}

/* designated initializer */
- (instancetype)init {
    if (self = [super init]) {
        _storeString = [[NSString alloc] init];
    }
    return self;
}

/* designated initializer */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _storeString = [[NSString alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    id string = [[self class] allocWithZone:zone];
    string = [string initWithString:_storeString];
    return string;
}

- (BOOL)isEqual:(id)object {
    return [_storeString isEqualToString:object];
}

- (NSUInteger)length {
    return [_storeString length];
}

- (unichar)characterAtIndex:(NSUInteger)index {
    return [_storeString characterAtIndex:index];
}

@end
