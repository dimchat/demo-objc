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

static inline NSString *document_directory(void) {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                NSUserDomainMask, YES);
    return paths.firstObject;
}

/**
 Get full filepath to Documents Directory
 
 @param ID - account ID
 @param filename - "meta.plist"
 @return "Documents/.mkm/{address}/meta.plist"
 */
static inline NSString *full_filepath(const MKMID *ID, NSString *filename) {
    assert(ID.isValid);
    // base directory: Documents/.mkm/{address}
    NSString *dir = document_directory();
    dir = [dir stringByAppendingPathComponent:@".mkm"];
    MKMAddress *addr = ID.address;
    if (addr) {
        dir = [dir stringByAppendingPathComponent:addr];
    }
    
    // check base directory exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir isDirectory:nil]) {
        NSError *error = nil;
        // make sure directory exists
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES
                       attributes:nil error:&error];
        assert(!error);
    }
    
    // build filepath
    return [dir stringByAppendingPathComponent:filename];
}

static inline BOOL file_exists(NSString *path) {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:path];
}

typedef NSMutableDictionary<const MKMAddress *, MKMContact *> ContactTableM;
typedef NSMutableDictionary<const MKMAddress *, MKMUser *> UserTableM;

typedef NSMutableDictionary<const MKMAddress *, MKMGroup *> GroupTableM;
typedef NSMutableDictionary<const MKMAddress *, MKMMember *> MemberTableM;
typedef NSMutableDictionary<const MKMAddress *, MemberTableM *> GroupMemberTableM;

typedef NSMutableDictionary<const MKMAddress *, MKMMeta *> MetaTableM;
typedef NSMutableDictionary<const MKMAddress *, MKMProfile *> ProfileTableM;

@interface MKMBarrack () {
    
    ContactTableM *_contactTable;
    UserTableM *_userTable;
    
    GroupTableM *_groupTable;
    GroupMemberTableM *_memberTables;
    
    MetaTableM *_metaTable;
    ProfileTableM *_profileTable;
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
        _contactTable = [[ContactTableM alloc] init];
        _userTable = [[UserTableM alloc] init];
        
        _groupTable = [[GroupTableM alloc] init];
        _memberTables = [[GroupMemberTableM alloc] init];
        
        _metaTable = [[MetaTableM alloc] init];
        _profileTable = [[ProfileTableM alloc] init];
    }
    return self;
}

- (void)reduceMemory {
    reduce_table(_contactTable);
    reduce_table(_userTable);
    
    reduce_table(_groupTable);
    reduce_table(_memberTables);
    
    reduce_table(_metaTable);
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
        MemberTableM *table = [_memberTables objectForKey:gAddr];
        if (!table) {
            table = [[MemberTableM alloc] init];
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
    MemberTableM *table = [_memberTables objectForKey:gID.address];
    MKMMember *member = [table objectForKey:ID.address];
    if (!member) {
        NSAssert(_memberDelegate, @"member delegate not set");
        member = [_memberDelegate memberWithID:ID groupID:gID];
        [self addMember:member];
    }
    return member;
}

#pragma mark - MKMEntityDataSource

- (MKMMeta *)loadMetaForEntityID:(const MKMID *)ID {
    MKMMeta *meta = nil;
    NSString *path = full_filepath(ID, @"meta.plist");
    if (file_exists(path)) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        meta = [[MKMMeta alloc] initWithDictionary:dict];
    }
    return meta;
}

- (BOOL)saveMeta:(const MKMMeta *)meta forEntityID:(const MKMID *)ID {
    if (![meta matchID:ID]) {
        NSAssert(!meta, @"meta error: %@, ID = %@", meta, ID);
        return NO;
    }
    NSString *path = full_filepath(ID, @"meta.plist");
    NSAssert(!file_exists(path), @"no need to update meta file");
    return [meta writeToBinaryFile:path];
}

- (MKMMeta *)metaForEntityID:(const MKMID *)ID {
    MKMMeta *meta;
    
    // 1. search in memory cache
    meta = [_metaTable objectForKey:ID.address];
    if (meta) {
        return meta;
    }
    
    // 2. search in local database
    meta = [self loadMetaForEntityID:ID];
    if (meta) {
        [_metaTable setObject:meta forKey:ID.address];
        return meta;
    }
    
    // 3. query from the network
    NSAssert(_entityDataSource, @"entity data source not set");
    meta = [_entityDataSource metaForEntityID:ID];
    
    // 4. store in local database
    if (meta && [self saveMeta:meta forEntityID:ID]) {
        [_metaTable setObject:meta forKey:ID.address];
    }
    
    return meta;
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
