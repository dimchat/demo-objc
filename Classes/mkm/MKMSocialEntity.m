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

#import "MKMSocialEntity.h"

@interface MKMSocialEntity ()

@property (strong, nonatomic) MKMID *founder;

@property (strong, nonatomic) NSArray<const MKMID *> *members;

@property (strong, nonatomic) MKMSocialEntityProfile *profile;

@end

@implementation MKMSocialEntity

- (instancetype)initWithID:(const MKMID *)ID {
    MKMID *founderID = nil;
    self = [self initWithID:ID founderID:founderID];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                 founderID:(const MKMID *)founderID {
    if (self = [super initWithID:ID]) {
        _founder = [founderID copy];
        _owner = nil;
        // lazy
        _members = nil;
        _profile = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMSocialEntity *social = [super copyWithZone:zone];
    if (social) {
        social.founder = _founder;
        social.owner = _owner;
        social.members = _members;
        social.profile = _profile;
    }
    return social;
}

- (BOOL)isFounder:(const MKMID *)ID {
    NSAssert(ID.isValid, @"Invalid ID");
    NSAssert(_founder, @"founder not set yet");
    return [_founder isEqual:ID];
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
    if (!_members) {
        _members = [[NSMutableArray alloc] init];
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

- (void)setName:(NSString *)name {
    if (!_profile) {
        _profile = [[MKMSocialEntityProfile alloc] init];
    }
    _profile.name = name;
    [super setName:name];
}

- (NSString *)name {
    NSString *str = _profile.name;
    if (str) {
        return str;
    }
    return [super name];
}

- (void)setLogo:(NSString *)logo {
    if (!_profile) {
        _profile = [[MKMSocialEntityProfile alloc] init];
    }
    _profile.logo = logo;
}

- (NSString *)logo {
    return _profile.logo;
}

- (void)updateProfile:(const MKMSocialEntityProfile *)profile {
    NSAssert([profile matchID:_ID], @"profile not match");
    if (!_profile) {
        _profile = [profile copy];
    } else {
        // TODO: update profiles
    }
}

@end
