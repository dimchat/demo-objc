//
//  MKMContact.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMContact.h"

@implementation MKMContact

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                 publicKey:(const MKMPublicKey *)PK {
    if (self = [super initWithID:ID publicKey:PK]) {
        //
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMContact *contact = [super copyWithZone:zone];
    if (contact) {
        //
    }
    return contact;
}

@end
