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

#import "MKMPolylogue.h"
#import "MKMChatroom.h"
#import "MKMMember.h"

#import "MKMProfile.h"

#import "MKMBarrack+LocalStorage.h"

#import "MKMBarrack.h"

typedef NSMutableDictionary<const MKMAddress *, MKMUser *> UserTableM;
typedef NSMutableDictionary<const MKMAddress *, MKMContact *> ContactTableM;

typedef NSMutableDictionary<const MKMAddress *, MKMGroup *> GroupTableM;
typedef NSMutableDictionary<const MKMAddress *, MKMMember *> MemberTableM;
typedef NSMutableDictionary<const MKMAddress *, MemberTableM *> GroupMemberTableM;

typedef NSMutableDictionary<const MKMAddress *, MKMMeta *> MetaTableM;

@interface MKMBarrack () {
    
    UserTableM *_userTable;
    ContactTableM *_contactTable;
    
    GroupTableM *_groupTable;
    GroupMemberTableM *_groupMemberTable;
    
    MetaTableM *_metaTable;
}

@end

/**
 Remove 1/2 objects from the dictionary
 
 @param mDict - mutable dictionary
 */
static inline void reduce_table(NSMutableDictionary *mDict) {
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
        _userTable = [[UserTableM alloc] init];
        _contactTable = [[ContactTableM alloc] init];
        
        _groupTable = [[GroupTableM alloc] init];
        _groupMemberTable = [[GroupMemberTableM alloc] init];
        
        _metaTable = [[MetaTableM alloc] init];
        
        // delegates
        _userDataSource = nil;
        _userDelegate = nil;
        _contactDelegate = nil;
        
        _groupDataSource = nil;
        _groupDelegate = nil;
        _memberDelegate = nil;
        _chatroomDataSource = nil;
        
        _entityDataSource = nil;
        _profileDataSource = nil;
    }
    return self;
}

- (void)reduceMemory {
    reduce_table(_userTable);
    reduce_table(_contactTable);
    
    reduce_table(_groupTable);
    reduce_table(_groupMemberTable);
    
    reduce_table(_metaTable);
}

- (void)addUser:(MKMUser *)user {
    MKMAddress *address = user.ID.address;
    NSAssert(address, @"address error");
    if (address.isValid) {
        [_userTable setObject:user forKey:address];
    }
}

- (void)addContact:(MKMContact *)contact {
    MKMAddress *address = contact.ID.address;
    NSAssert(address, @"address error");
    if (address.isValid) {
        [_contactTable setObject:contact forKey:address];
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
        MemberTableM *table = [_groupMemberTable objectForKey:gAddr];
        if (!table) {
            table = [[MemberTableM alloc] init];
            [_groupMemberTable setObject:table forKey:gAddr];
        }
        [table setObject:member forKey:uAddr];
    }
}

- (void)setMeta:(MKMMeta *)meta forID:(const MKMID *)ID {
    if (meta) {
        NSAssert([meta matchID:ID], @"meta error: %@, ID = %@", meta, ID);
        [_metaTable setObject:meta forKey:ID.address];
    } else {
        [_metaTable removeObjectForKey:ID.address];
    }
}

#pragma mark - MKMUserDataSource

- (NSInteger)numberOfContactsInUser:(const MKMUser *)usr {
    NSAssert(MKMNetwork_IsPerson(usr.ID.type), @"not a user: %@", usr);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource numberOfContactsInUser:usr];
}

- (MKMID *)user:(const MKMUser *)usr contactAtIndex:(NSInteger)index {
    NSAssert(MKMNetwork_IsPerson(usr.ID.type), @"not a user: %@", usr);
    NSAssert(_userDataSource, @"user data source not set");
    return [_userDataSource user:usr contactAtIndex:index];
}

#pragma mark - MKMUserDelegate

- (MKMUser *)userWithID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"not a person ID: %@", ID);
    MKMUser *user = [_userTable objectForKey:ID.address];
    while (!user) {
        // create by delegate
        NSAssert(_userDelegate, @"user delegate not set");
        user = [_userDelegate userWithID:ID];
        if (user) {
            [self addUser:user];
            break;
        }
        
        // create directly if we can find public key
        MKMPublicKey *PK = MKMPublicKeyForID(ID);
        if (PK) {
            user = [[MKMUser alloc] initWithID:ID publicKey:PK];
        } else {
            NSAssert(false, @"failed to get PK for user: %@", ID);
        }
        
        // add contacts
        NSInteger count = [self numberOfContactsInUser:user];
        for (NSInteger index = 0; index < count; ++index) {
            [user addContact:[self user:user contactAtIndex:index]];
        }
        
        [self addUser:user];
        break;
    }
    return user;
}

#pragma mark MKMContactDelegate

- (MKMContact *)contactWithID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"not a person ID: %@", ID);
    MKMContact *contact = [_contactTable objectForKey:ID.address];
    while (!contact) {
        // create by delegate
        NSAssert(_contactDelegate, @"contact delegate not set");
        contact = [_contactDelegate contactWithID:ID];
        if (contact) {
            [self addContact:contact];
            break;
        }
        
        // create directly if we can find public key
        MKMPublicKey *PK = MKMPublicKeyForID(ID);
        if (PK) {
            contact = [[MKMContact alloc] initWithID:ID publicKey:PK];
        } else {
            NSAssert(false, @"PK not found for contact: %@", ID);
        }
        
        [self addContact:contact];
        break;
    }
    return contact;
}

#pragma mark MKMGroupDataSource

- (MKMID *)founderForGroupID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"not a group ID: %@", ID);
    MKMGroup *group = [_groupTable objectForKey:ID.address];
    MKMID *founder = group.founder;
    if (founder) {
        return founder;
    }
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource founderForGroupID:ID];
}

- (MKMID *)ownerForGroupID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"not a group ID: %@", ID);
    MKMGroup *group = [_groupTable objectForKey:ID.address];
    MKMID *owner = group.owner;
    if (owner) {
        return owner;
    }
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource ownerForGroupID:ID];
}

- (NSInteger)numberOfMembersInGroup:(const MKMGroup *)grp {
    NSAssert(MKMNetwork_IsGroup(grp.ID.type), @"not a group: %@", grp);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource numberOfMembersInGroup:grp];
}

- (MKMID *)group:(const MKMGroup *)grp memberAtIndex:(NSInteger)index {
    NSAssert(MKMNetwork_IsGroup(grp.ID.type), @"not a group: %@", grp);
    NSAssert(_groupDataSource, @"group data source not set");
    return [_groupDataSource group:grp memberAtIndex:index];
}

#pragma mark MKMGroupDelegate

- (MKMGroup *)groupWithID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsGroup(ID.type), @"not a group ID: %@", ID);
    MKMGroup *group = [_groupTable objectForKey:ID.address];
    while (!group) {
        // create by delegate
        NSAssert(_groupDelegate, @"group delegate not set");
        group = [_groupDelegate groupWithID:ID];
        if (group) {
            [self addGroup:group];
            break;
        }
        
        // get founder of this group
        MKMID *founder = [self founderForGroupID:ID];
        if (!founder) {
            NSAssert(false, @"founder not found for group: %@", ID);
            break;
        }
        
        // create it
        if (ID.type == MKMNetwork_Polylogue) {
            group = [[MKMPolylogue alloc] initWithID:ID founderID:founder];
        } else if (ID.type == MKMNetwork_Chatroom) {
            group = [[MKMChatroom alloc] initWithID:ID founderID:founder];
        } else {
            NSAssert(false, @"group error: %@", ID);
        }
        // set owner
        group.owner = [self ownerForGroupID:ID];
        // add members
        NSInteger count = [self numberOfMembersInGroup:group];
        NSInteger index;
        for (index = 0; index < count; ++index) {
            [group addMember:[self group:group memberAtIndex:index]];
        }
        // add admins
        if (ID.type == MKMNetwork_Chatroom) {
            MKMChatroom *chatroom = (MKMChatroom *)group;
            count = [self numberOfAdminsInChatroom:chatroom];
            for (index = 0; index < count; ++index) {
                [chatroom addAdmin:[self chatroom:chatroom adminAtIndex:index]];
            }
        }
        
        [self addGroup:group];
        break;
    }
    return group;
}

#pragma mark MKMMemberDelegate

- (MKMMember *)memberWithID:(const MKMID *)ID groupID:(const MKMID *)gID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"not a person ID: %@", ID);
    NSAssert(MKMNetwork_IsGroup(gID.type), @"not a group ID: %@", gID);
    MemberTableM *table = [_groupMemberTable objectForKey:gID.address];
    MKMMember *member = [table objectForKey:ID.address];
    while (!member) {
        // create by delegate
        NSAssert(_memberDelegate, @"member delegate not set");
        member = [_memberDelegate memberWithID:ID groupID:gID];
        if (member) {
            [self addMember:member];
            break;
        }
        
        // create directly if we can find public key
        MKMPublicKey *PK = MKMPublicKeyForID(ID);
        if (PK) {
            member = [[MKMMember alloc] initWithGroupID:gID
                                              accountID:ID
                                              publicKey:PK];
        } else {
            NSAssert(false, @"PK not found for member: %@", ID);
        }
        
        [self addMember:member];
        break;
    }
    return member;
}
                     
#pragma mark MKMChatroomDataSource

- (NSInteger)numberOfAdminsInChatroom:(const MKMChatroom *)grp {
    NSAssert(grp.ID.type == MKMNetwork_Chatroom, @"not a chatroom: %@", grp);
    NSAssert(_chatroomDataSource, @"chatroom data source not set");
    return [_chatroomDataSource numberOfAdminsInChatroom:grp];
}

- (MKMID *)chatroom:(const MKMChatroom *)grp adminAtIndex:(NSInteger)index {
    NSAssert(grp.ID.type == MKMNetwork_Chatroom, @"not a chatroom: %@", grp);
    NSAssert(_chatroomDataSource, @"chatroom data source not set");
    return [_chatroomDataSource chatroom:grp adminAtIndex:index];
}

#pragma mark - MKMEntityDataSource

- (MKMMeta *)metaForEntityID:(const MKMID *)ID {
    MKMMeta *meta;
    
    // 1. search in memory cache
    meta = [_metaTable objectForKey:ID.address];
    if (meta) {
        return meta;
    }
    
    // 2. check data source
    if (_entityDataSource) {
        // 2.1. query from the network
        meta = [_entityDataSource metaForEntityID:ID];
    } else {
        // 2.2. load from local storage
        meta = [self loadMetaForEntityID:ID];
    }
    NSAssert(meta, @"failed to get meta for ID: %@", ID);
    
    // 3. store in memory cache
    [self setMeta:meta forID:ID];
    
    return meta;
}

#pragma mark - MKMProfileDataSource

- (MKMProfile *)profileForID:(const MKMID *)ID {
    //NSAssert(_profileDataSource, @"profile data source not set");
    MKMProfile *profile = [_profileDataSource profileForID:ID];
    //NSAssert(profile, @"failed to get profile for ID: %@", ID);
    return profile;
}

@end
