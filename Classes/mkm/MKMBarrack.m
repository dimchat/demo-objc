//
//  MKMBarrack.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMMeta.h"

#import "MKMUser.h"
#import "MKMContact.h"
#import "MKMGroup.h"
#import "MKMMember.h"

#import "MKMProfile.h"

#import "MKMBarrack.h"

typedef NSMutableDictionary<const MKMAddress *, MKMContact *> ContactTable;
typedef NSMutableDictionary<const MKMAddress *, MKMUser *> UserTable;

typedef NSMutableDictionary<const MKMAddress *, MKMGroup *> GroupTable;
typedef NSMutableDictionary<const MKMAddress *, MKMMember *> MemberTable;
typedef NSMutableDictionary<const MKMAddress *, MemberTable *> GroupMemberTable;

typedef NSMutableDictionary<const MKMAddress *, MKMProfile *> ProfileTable;

@interface MKMBarrack () {
    
    ContactTable *_contactTable;
    UserTable *_userTable;
    
    GroupTable *_groupTable;
    GroupMemberTable *_memberTables;
    
    ProfileTable *_profileTable;
}

@end

/**
 Remove 1/2 objects from the dictionary
 
 @param mDict - mutable dictionary
 */
static void reduce_table(NSMutableDictionary *mDict) {
    NSArray *keys = [mDict allKeys];
    MKMAddress *addr;
    for (NSUInteger index = 0; index < keys.count; index += 2) {
        addr = [keys objectAtIndex:index];
        [mDict removeObjectForKey:addr];
    }
}

@implementation MKMBarrack

SingletonImplementations(MKMBarrack, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _contactTable = [[ContactTable alloc] init];
        _userTable = [[UserTable alloc] init];
        
        _groupTable = [[GroupTable alloc] init];
        _memberTables = [[GroupMemberTable alloc] init];
        
        _profileTable = [[ProfileTable alloc] init];
    }
    return self;
}

- (void)reduceMemory {
    reduce_table(_contactTable);
    reduce_table(_userTable);
    
    reduce_table(_groupTable);
    reduce_table(_memberTables);
    
    reduce_table(_profileTable);
}

- (void)addContact:(MKMContact *)contact {
    MKMAddress *address = contact.ID.address;
    NSAssert(address, @"address error");
    if (address.isValid) {
        [_contactTable setObject:contact forKey:address];
    }
}

- (void)addUser:(MKMUser *)user {
    MKMAddress *address = user.ID.address;
    NSAssert(address, @"address error");
    if (address.isValid) {
        [_userTable setObject:user forKey:address];
    }
}

- (void)addGroup:(MKMGroup *)group {
    MKMAddress *address = group.ID.address;
    NSAssert(address, @"address error");
    if (address.isValid) {
        [_groupTable setObject:group forKey:address];
    }
}

- (void)addMember:(MKMMember *)member {
    MKMAddress *gAddr = member.groupID.address;
    MKMAddress *uAddr = member.ID.address;
    NSAssert(gAddr, @"group address error");
    NSAssert(uAddr, @"address error");
    if (gAddr.isValid && uAddr.isValid) {
        MemberTable *table = [_memberTables objectForKey:gAddr];
        if (!table) {
            table = [[MemberTable alloc] init];
            [_memberTables setObject:table forKey:gAddr];
        }
        [table setObject:member forKey:uAddr];
    }
}

- (void)addProfile:(MKMProfile *)profile {
    MKMAddress *address = profile.ID.address;
    NSAssert(address, @"address error");
    if (address.isValid) { // [profile matchID:ID]
        [_profileTable setObject:profile forKey:address];
    }
}

#pragma mark - MKMUserDelegate

- (MKMUser *)userWithID:(const MKMID *)ID {
    MKMUser *user = [_userTable objectForKey:ID.address];
    if (!user) {
        NSAssert(_userDelegate, @"user delegate not set");
        user = [_userDelegate userWithID:ID];
        [self addUser:user];
    }
    return user;
}

#pragma mark MKMContactDelegate

- (MKMContact *)contactWithID:(const MKMID *)ID {
    MKMContact *contact = [_contactTable objectForKey:ID.address];
    if (!contact) {
        NSAssert(_contactDelegate, @"contact delegate not set");
        contact = [_contactDelegate contactWithID:ID];
        [self addContact:contact];
    }
    return contact;
}

#pragma mark MKMGroupDelegate

- (MKMGroup *)groupWithID:(const MKMID *)ID {
    MKMGroup *group = [_groupTable objectForKey:ID.address];
    if (!group) {
        NSAssert(_groupDelegate, @"group delegate not set");
        group = [_groupDelegate groupWithID:ID];
        [self addGroup:group];
    }
    return group;
}

#pragma mark MKMMemberDelegate

- (MKMMember *)memberWithID:(const MKMID *)ID groupID:(const MKMID *)gID {
    MemberTable *table = [_memberTables objectForKey:gID.address];
    MKMMember *member = [table objectForKey:ID.address];
    if (!member) {
        NSAssert(_memberDelegate, @"member delegate not set");
        member = [_memberDelegate memberWithID:ID groupID:gID];
        [self addMember:member];
    }
    return member;
}

#pragma mark - MKMEntityDataSource

- (MKMMeta *)metaForEntityID:(const MKMID *)ID {
    NSAssert(_entityDataSource, @"entity data source not set");
    return [_entityDataSource metaForEntityID:ID];
}

#pragma mark MKMAccountDataSource

- (MKMPublicKey *)publicKeyForAccountID:(const MKMID *)ID {
    // try contacts
    MKMContact *contact = [_contactTable objectForKey:ID.address];
    if (contact) {
        return contact.publicKey;
    }
    // try users
    MKMUser *user = [_userTable objectForKey:ID.address];
    if (user) {
        return user.publicKey;
    }
    
    NSAssert(_accountDataSource, @"account data source not set");
    return [_accountDataSource publicKeyForAccountID:ID];
}

#pragma mark - MKMProfileDataSource

- (MKMProfile *)profileForID:(const MKMID *)ID {
    MKMProfile *profile = [_profileTable objectForKey:ID.address];
    if (!profile) {
        NSAssert(_profileDataSource, @"profile data source not set");
        profile = [_profileDataSource profileForID:ID];
        [self addProfile:profile];
    }
    return profile;
}

@end
