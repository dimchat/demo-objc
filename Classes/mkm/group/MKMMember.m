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

@end

@implementation MKMMember

- (instancetype)initWithID:(const MKMID *)ID
                 publicKey:(const MKMPublicKey *)PK {
    //NSAssert(false, @"DON'T call me");
    MKMID *groupID = nil;
    self = [self initWithGroupID:groupID accountID:ID publicKey:PK];
    return self;
}

/* designated initializer */
- (instancetype)initWithGroupID:(const MKMID *)groupID
                      accountID:(const MKMID *)ID
                      publicKey:(const MKMPublicKey *)PK {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"member ID error");
    NSAssert(!groupID || MKMNetwork_IsGroup(groupID.type), @"group ID error");
    if (self = [super initWithID:ID publicKey:PK]) {
        _groupID = [groupID copy];
        _role = MKMMember_Member;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMMember *member = [super copyWithZone:zone];
    if (member) {
        member.groupID = _groupID;
        member.role = _role;
    }
    return member;
}

@end

#pragma mark -

@implementation MKMFounder

- (instancetype)initWithGroupID:(const MKMID *)groupID
                      accountID:(const MKMID *)ID
                      publicKey:(const MKMPublicKey *)PK {
    if (self = [super initWithGroupID:groupID accountID:ID publicKey:PK]) {
        _role = MKMMember_Founder;
    }
    return self;
}

@end

@implementation MKMOwner

- (instancetype)initWithGroupID:(const MKMID *)groupID
                      accountID:(const MKMID *)ID
                      publicKey:(const MKMPublicKey *)PK {
    if (self = [super initWithGroupID:groupID accountID:ID publicKey:PK]) {
        _role = MKMMember_Owner;
    }
    return self;
}

@end

@implementation MKMAdmin

- (instancetype)initWithGroupID:(const MKMID *)groupID
                      accountID:(const MKMID *)ID
                      publicKey:(const MKMPublicKey *)PK {
    if (self = [super initWithGroupID:groupID accountID:ID publicKey:PK]) {
        _role = MKMMember_Admin;
    }
    return self;
}

@end
