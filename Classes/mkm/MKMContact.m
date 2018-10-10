//
//  MKMContact.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMProfile.h"
#import "MKMMemo.h"

#import "MKMContact.h"

@implementation MKMContact

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _memo = [[MKMContactMemo alloc] init];
    }
    
    return self;
}

@end
