//
//  DIMBarrack.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMUser.h"
#import "DIMContact.h"
#import "DIMGroup.h"
#import "DIMMember.h"

#import "DIMBarrack.h"

typedef NSMutableDictionary<const MKMAddress *, DIMContact *> ContactTable;
typedef NSMutableDictionary<const MKMAddress *, DIMUser *> UserTable;

typedef NSMutableDictionary<const MKMAddress *, DIMGroup *> GroupTable;
typedef NSMutableDictionary<const MKMAddress *, DIMMember *> MemberTable;
typedef NSMutableDictionary<const MKMAddress *, MemberTable *> GroupMemberTable;

typedef NSMutableDictionary<const MKMAddress *, MKMProfile *> ProfileTable;

@interface DIMBarrack () {
    
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

/**
 Load built-in accounts for test

 @param filename - immortal account data file
 */
static void load_immortal_file(NSString *filename, DIMBarrack *barrack) {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:filename ofType:@"plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        NSLog(@"file not exists: %@", path);
        return ;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // ID
    MKMID *ID = [dict objectForKey:@"ID"];
    ID = [MKMID IDWithID:ID];
    assert(ID.isValid);
    
    // meta
    MKMMeta *meta = [dict objectForKey:@"meta"];
    meta = [MKMMeta metaWithMeta:meta];
    assert([meta matchID:ID]);
    
    // profile
    id profile = [dict objectForKey:@"profile"];
    if (profile) {
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
        [mDict setObject:ID forKey:@"ID"];
        [mDict addEntriesFromDictionary:profile];
        profile = mDict;
    }
    profile = [MKMAccountProfile profileWithProfile:profile];
    assert(profile);
    
    // 1. create contact & user
    DIMUser *user = [[DIMUser alloc] initWithID:ID
                                      publicKey:meta.key];
    DIMContact *contact = [[DIMContact alloc] initWithID:ID
                                               publicKey:meta.key];
    
    // 2. save entities into barrack
    [barrack addUser:user];
    [barrack addContact:contact];
    
    // 3. store private key into keychain
    MKMPrivateKey *SK = [dict objectForKey:@"privateKey"];
    SK = [MKMPrivateKey keyWithKey:SK];
    assert(SK.algorithm);
    [SK saveKeyWithIdentifier:ID.address];
    
    // 4. save profiles into barrack
    [barrack addProfile:profile];
}

@implementation DIMBarrack

SingletonImplementations(DIMBarrack, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _contactTable = [[ContactTable alloc] init];
        _userTable = [[UserTable alloc] init];
        
        _groupTable = [[GroupTable alloc] init];
        _memberTables = [[GroupMemberTable alloc] init];
        
        _profileTable = [[ProfileTable alloc] init];
        
#if DEBUG
        // Immortals
        load_immortal_file(@"mkm_hulk", self);
        load_immortal_file(@"mkm_moki", self);
#endif
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

- (void)addContact:(DIMContact *)contact {
    MKMAddress *address = contact.ID.address;
    NSAssert(address, @"address error");
    if (address.isValid) {
        [_contactTable setObject:contact forKey:address];
    }
}

- (void)addUser:(DIMUser *)user {
    MKMAddress *address = user.ID.address;
    NSAssert(address, @"address error");
    if (address.isValid) {
        [_userTable setObject:user forKey:address];
    }
}

- (void)addGroup:(DIMGroup *)group {
    MKMAddress *address = group.ID.address;
    NSAssert(address, @"address error");
    if (address.isValid) {
        [_groupTable setObject:group forKey:address];
    }
}

- (void)addMember:(DIMMember *)member {
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

#pragma mark - DIMAccountDelegate

- (DIMUser *)userWithID:(const MKMID *)ID {
    DIMUser *user = [_userTable objectForKey:ID.address];
    if (!user) {
        NSAssert(_accountDelegate, @"account delegate not set");
        user = [_accountDelegate userWithID:ID];
        [self addUser:user];
    }
    return user;
}

- (DIMContact *)contactWithID:(const MKMID *)ID {
    DIMContact *contact = [_contactTable objectForKey:ID.address];
    if (!contact) {
        NSAssert(_accountDelegate, @"account delegate not set");
        contact = [_accountDelegate contactWithID:ID];
        [self addContact:contact];
    }
    return contact;
}

#pragma mark - DIMGroupDelegate

- (DIMGroup *)groupWithID:(const MKMID *)ID {
    DIMGroup *group = [_groupTable objectForKey:ID.address];
    if (!group) {
        NSAssert(_groupDelegate, @"group delegate not set");
        group = [_groupDelegate groupWithID:ID];
        [self addGroup:group];
    }
    return group;
}

- (DIMMember *)memberWithID:(const MKMID *)ID groupID:(const MKMID *)gID {
    MemberTable *table = [_memberTables objectForKey:gID.address];
    DIMMember *member = [table objectForKey:ID.address];
    if (!member) {
        NSAssert(_groupDelegate, @"group delegate not set");
        member = [_groupDelegate memberWithID:ID groupID:gID];
        [self addMember:member];
    }
    return member;
}

#pragma mark - DIMProfileDataSource

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
