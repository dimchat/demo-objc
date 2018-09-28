//
//  MKMString.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMString.h"

@implementation MKMString

- (instancetype)initWithString:(NSString *)aString {
    if (self = [self init]) {
        _storeString = [aString copy];
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
