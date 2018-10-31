//
//  MKMSocialEntity.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMEntityManager.h"

#import "MKMSocialEntity.h"

@interface MKMSocialEntity ()

@property (strong, nonatomic) MKMID *founder;
@property (strong, nonatomic) MKMID *owner;

@property (strong, nonatomic) NSArray<const MKMID *> *members;

@property (strong, nonatomic) MKMSocialEntityProfile *profile;

@end

@implementation MKMSocialEntity

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _members = [[NSMutableArray alloc] init];
        _profile = [[MKMSocialEntityProfile alloc] init];
    }
    
    return self;
}

- (id)copy {
    MKMSocialEntity *social = [super copy];
    if (social) {
        social.founder = _founder;
        social.owner = _owner;
        social.members = _members;
        social.profile = _profile;
    }
    return social;
}

- (BOOL)isFounder:(const MKMID *)ID {
    if (_founder) {
        return [_founder isEqual:ID];
    }
    // founder not set yet, check by meta.key
    MKMMeta *meta = MKMMetaForID(ID);
    MKMPublicKey *PK = MKMPublicKeyForAccountID(ID);
    // the key in social entity's meta
    // must be the same (public) key of founder
    return [meta.key isEqual:PK];
}

- (BOOL)isOwner:(const MKMID *)ID {
    NSAssert(ID.isValid, @"Invalid ID");
    NSAssert(_owner, @"owner not set yet");
    return [_owner isEqual:ID];
}

- (void)addMember:(const MKMID *)ID {
    NSAssert(ID.isValid, @"Invalid ID");
    if ([self isMember:ID]) {
        // don't add same member twice
        return;
    }
    [_members addObject:ID];
}

- (void)removeMember:(const MKMID *)ID {
    NSAssert([self isMember:ID], @"no such member found");
    [_members removeObject:ID];
}

- (BOOL)isMember:(const MKMID *)ID {
    NSAssert(ID.isValid, @"Invalid ID");
    return [_members containsObject:ID];
}

@end

@implementation MKMSocialEntity (Profile)

- (NSString *)name {
    NSString *str = _profile.name;
    if (!str) {
        str = _ID.name;
    }
    return str;
}

- (NSString *)logo {
    return _profile.logo;
}

- (void)updateProfile:(const MKMSocialEntityProfile *)profile {
    NSAssert([profile matchID:_ID], @"profile not match");
    // TODO: update profiles
}

@end
