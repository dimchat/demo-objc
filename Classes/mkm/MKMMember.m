//
//  MKMMember.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"

#import "MKMMember.h"

@interface MKMMember ()

@property (strong, nonatomic) MKMID *groupID;
@property (nonatomic) MKMMemberType type;

@end

@implementation MKMMember

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                 publicKey:(const MKMPublicKey *)PK {
    MKMID *gID = nil;
    self = [self initWithGroupID:gID
                          userID:ID
                       publicKey:PK];
    return self;
}

- (instancetype)initWithGroupID:(const MKMID *)groupID
                         userID:(const MKMID *)ID
                      publicKey:(const MKMPublicKey *)PK {
    if (self = [super initWithID:ID publicKey:PK]) {
        _groupID = [groupID copy];
        _type = MKMMember_Other;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMMember *member = [super copyWithZone:zone];
    if (member) {
        member.groupID = _groupID;
        member.type = _type;
    }
    return member;
}

@end
