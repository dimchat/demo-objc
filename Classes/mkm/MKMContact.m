//
//  MKMContact.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMMemo.h"

#import "MKMContact.h"

@interface MKMContact ()

@property (strong, nonatomic) MKMContactMemo *memo;

@end

@implementation MKMContact

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                 publicKey:(const MKMPublicKey *)PK {
    if (self = [super initWithID:ID publicKey:PK]) {
        // lazy
        _memo = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMContact *contact = [super copyWithZone:zone];
    if (contact) {
        contact.memo = _memo;
    }
    return contact;
}

@end
