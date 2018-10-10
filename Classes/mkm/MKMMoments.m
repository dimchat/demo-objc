//
//  MKMMoments.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMMoments.h"

@implementation MKMMoments

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _exclusions = [[NSMutableArray alloc] init];
        _ignores = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end
