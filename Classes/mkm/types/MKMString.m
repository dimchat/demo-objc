//
//  MKMString.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
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

- (id)copy {
    return [[[self class] alloc] initWithString:_storeString];
}

- (NSUInteger)length {
    return [_storeString length];
}

- (unichar)characterAtIndex:(NSUInteger)index {
    return [_storeString characterAtIndex:index];
}

@end
