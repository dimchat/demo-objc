//
//  MKMContact.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMMemo.h"

#import "MKMContact.h"

@interface MKMContact ()

@property (strong, nonatomic) MKMContactMemo *memo;

@end

@implementation MKMContact

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _memo = [[MKMContactMemo alloc] init];
    }
    
    return self;
}

- (id)copy {
    MKMContact *contact = [super copy];
    if (contact) {
        contact.memo = _memo;
    }
    return contact;
}

@end
