//
//  DIMFacebook.m
//  DIMClient
//
//  Created by Albert Moky on 2019/6/26.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSDate+Timestamp.h"

#import "MKMECCPrivateKey.h"
#import "MKMECCPublicKey.h"
#import "MKMAddressETH.h"
#import "MKMMetaETH.h"

#import "DIMServer.h"

#import "DIMFacebook+Storage.h"
#import "DIMFacebook.h"

@interface DIMFacebook (Hacking)

- (BOOL)_storeMeta:(DIMMeta *)meta forID:(DIMID *)ID;
- (BOOL)_storeProfile:(DIMProfile *)profile;
- (BOOL)_storeContacts:(NSArray *)contacts forUser:(DIMLocalUser *)user;
- (BOOL)_storeMembers:(NSArray *)members forGroup:(DIMGroup *)group;

@end

typedef NSMutableDictionary<DIMID *, DIMProfile *> ProfileTableM;

typedef NSMutableArray<DIMID *> ContactTableM;
typedef NSMutableDictionary<DIMAddress *, ContactTableM *> ContactMapM;

@interface DIMFacebook () {
    
    // memory caches
    ProfileTableM *_profileTable;
    ContactMapM *_contactMap;
    
    // delegates
    __weak __kindof id<DIMEntityDataSource> _entityDataSource;
    __weak __kindof id<DIMUserDataSource> _userDataSource;
    __weak __kindof id<DIMGroupDataSource> _groupDataSource;
}

@end

@implementation DIMFacebook

SingletonImplementations(DIMFacebook, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        // memory caches
        _profileTable = [[ProfileTableM alloc] init];
        _contactMap = [[ContactMapM alloc] init]; // contacts list of each user
        
        // register new asymmetric cryptography key classes
        [MKMPrivateKey registerClass:[MKMECCPrivateKey class] forAlgorithm:ACAlgorithmECC];
        [MKMPublicKey registerClass:[MKMECCPublicKey class] forAlgorithm:ACAlgorithmECC];
        
        // register new address classes
        //[MKMAddress registerClass:[MKMAddressETH class]];
        
        // register new meta classes
        [MKMMeta registerClass:[MKMMetaBTC class] forVersion:MKMMetaVersion_BTC];
        [MKMMeta registerClass:[MKMMetaBTC class] forVersion:MKMMetaVersion_ExBTC];
        [MKMMeta registerClass:[MKMMetaETH class] forVersion:MKMMetaVersion_ETH];
        [MKMMeta registerClass:[MKMMetaETH class] forVersion:MKMMetaVersion_ExETH];
    }
    return self;
}

- (BOOL)_verifyProfile:(DIMProfile *)profile {
    if (!profile) {
        return NO;
    } else if ([profile isValid]) {
        // already verified
        return YES;
    }
    DIMID *ID = profile.ID;
    NSAssert([ID isValid], @"profile ID not valid: %@", profile);
    DIMMeta *meta = nil;
    // check signer
    if (MKMNetwork_IsUser(ID.type)) {
        // verify with user's meta.key
        meta = [self metaForID:ID];
    } else if (MKMNetwork_IsGroup(ID.type)) {
        if (ID.type == MKMNetwork_Polylogue) {
            // verify with group found's key (AKA meta.key)
            meta = [self metaForID:ID];
        } else {
            // verify with group owner's meta.key
            DIMGroup *group = [self groupWithID:ID];
            DIMID *owner = group.owner;
            if ([owner isValid]) {
                meta = [self metaForID:owner];
            }
        }
    }
    return [profile verify:meta.key];
}

- (BOOL)cacheProfile:(DIMProfile *)profile {
    if (![self _verifyProfile:profile]) {
        NSLog(@"profile not valid: %@", profile);
        return NO;
    }
    [_profileTable setObject:profile forKey:profile.ID];
    return YES;
}

#pragma mark - DIMSocialNetworkDataSource

- (nullable __kindof DIMUser *)userWithID:(DIMID *)ID {
    DIMUser *user = [super userWithID:ID];
    if (user) {
        return user;
    }
    // check meta and private key
    DIMMeta *meta = DIMMetaForID(ID);
    if (!meta) {
        NSLog(@"meta key not found: %@", ID);
        return nil;
    }
    if (MKMNetwork_IsPerson(ID.type)) {
        DIMPrivateKey *key = [self privateKeyForSignatureOfUser:ID];
        if (!key) {
            user = [[DIMContact alloc] initWithID:ID];
        } else {
            user = [[DIMLocalUser alloc] initWithID:ID];
        }
    } else if (MKMNetwork_IsRobot(ID.type)) {
        user = [[DIMRobot alloc] initWithID:ID];
    } else if (MKMNetwork_IsStation(ID.type)) {
        // FIXME: make sure the station not been erased from the memory cache
        user = [[DIMServer alloc] initWithID:ID];
    } else {
        // TODO: implements other types
        NSAssert(false, @"user type not support: %@", ID);
    }
    [self cacheUser:user];
    return user;
}

- (nullable __kindof DIMGroup *)groupWithID:(DIMID *)ID {
    DIMGroup *group = [super groupWithID:ID];
    if (group) {
        return group;
    }
    // check meta
    DIMMeta *meta = DIMMetaForID(ID);
    if (!meta) {
        NSLog(@"meta not found: %@", ID);
        return nil;
    }
    // create it with type
    if (ID.type == MKMNetwork_Polylogue) {
        group = [[DIMPolylogue alloc] initWithID:ID];
    } else if (ID.type == MKMNetwork_Chatroom) {
        group = [[DIMChatroom alloc] initWithID:ID];
    } else {
        // TODO: implements other types
        NSAssert(false, @"group type not support: %@", ID);
    }
    [self cacheGroup:group];
    return group;
}

#pragma mark - MKMEntityDataSource

- (nullable DIMMeta *)metaForID:(DIMID *)ID {
    DIMMeta *meta = [super metaForID:ID];
    if (meta) {
        return meta;
    }
    // load from local storage
    meta = [self loadMetaForID:ID];
    if (!meta) {
        return nil;
    }
    // check and cache it
    if (![self cacheMeta:meta forID:ID]) {
        NSAssert(false, @"meta error: %@ -> %@", ID, meta);
        return nil;
    }
    return meta;
}

- (nullable __kindof DIMProfile *)profileForID:(MKMID *)ID {
    DIMProfile *profile = [super profileForID:ID];
    if ([profile objectForKey:@"data"]) {
        return profile;
    }
    // get from profile cache
    profile = [_profileTable objectForKey:ID];
    if (profile) {
        // check timestamp
        NSNumber *timestamp = [profile objectForKey:@"lastTime"];
        if (timestamp) {
            NSDate *lastTime = NSDateFromNumber(timestamp);
            NSTimeInterval ti = [lastTime timeIntervalSinceNow];
            if (fabs(ti) < 3600) {
                // not expired yet
                return profile;
            }
            NSLog(@"profile expired: %@", lastTime);
            [_profileTable removeObjectForKey:ID];
        } else {
            // set last update time
            NSDate *now = [[NSDate alloc] init];
            [profile setObject:NSNumberFromDate(now) forKey:@"lastTime"];
            return profile;
        }
    }
    // get from entity data source
    profile = [_entityDataSource profileForID:ID];
    if (!profile) {
        // load from local storage
        profile = [self loadProfileForID:ID];
    }
    // check and cache it
    if (!profile || ![self cacheProfile:profile]) {
        // place an empty profile for cache
        profile = [[DIMProfile alloc] initWithID:ID];
    }
    [_profileTable setObject:profile forKey:profile.ID];
    return profile;
}

#pragma mark - MKMUserDataSource

- (nullable DIMPrivateKey *)privateKeyForSignatureOfUser:(DIMID *)user {
    DIMPrivateKey *key = [super privateKeyForSignatureOfUser:user];
    if (key) {
        return key;
    }
    return [DIMPrivateKey loadKeyWithIdentifier:user.address];
}

- (nullable NSArray<DIMPrivateKey *> *)privateKeysForDecryptionOfUser:(DIMID *)user {
    NSArray<DIMPrivateKey *> *keys = [super privateKeysForDecryptionOfUser:user];
    if (keys) {
        return keys;
    }
    DIMPrivateKey *key = [self privateKeyForSignatureOfUser:user];
    if (key) {
        keys = [[NSArray alloc] initWithObjects:key, nil];
    }
    return keys;
}

- (nullable NSArray<DIMID *> *)contactsOfUser:(DIMID *)user {
    NSArray<DIMID *> *contacts = [super contactsOfUser:user];
    if (contacts) {
        return contacts;
    }
    contacts = [_contactMap objectForKey:user.address];
    if (contacts) {
        return contacts;
    }
    contacts = [self loadContactsForUser:user];
    if (contacts) {
        [_contactMap setObject:(ContactTableM *)contacts forKey:user.address];
    }
    return contacts;
}

#pragma mark - MKMGroupDataSource

- (nullable DIMID *)founderOfGroup:(DIMID *)group {
    DIMID *founder = [super founderOfGroup:group];
    if (founder) {
        return founder;
    }
    // check each member's public key with group meta
    DIMMeta *gMeta = [self metaForID:group];
    NSArray<DIMID *> *members = [self membersOfGroup:group];
    DIMMeta *meta;
    for (DIMID *member in members) {
        // if the user's public key matches with the group's meta,
        // it means this meta was generate by the user's private key
        meta = [self metaForID:member];
        if ([gMeta matchPublicKey:meta.key]) {
            return member;
        }
    }
    return nil;
}

- (nullable DIMID *)ownerOfGroup:(DIMID *)group {
    DIMID *owner = [super ownerOfGroup:group];
    if (owner) {
        return owner;
    }
    if (group.type == MKMNetwork_Polylogue) {
        // the polylogue's owner is its founder
        return [self founderOfGroup:group];
    }
    return nil;
}

- (nullable NSArray<DIMID *> *)membersOfGroup:(DIMID *)group {
    NSArray<DIMID *> *members = [super membersOfGroup:group];
    if (members) {
        return members;
    }
    members = [_contactMap objectForKey:group.address];
    if (members) {
        return members;
    }
    members = [self loadMembersForGroup:group];
    if (members) {
        [_contactMap setObject:(ContactTableM *)members forKey:group.address];
    }
    return members;
}

@end

@implementation DIMFacebook (Relationship)

- (BOOL)user:(DIMLocalUser *)user addContact:(DIMID *)contact {
    NSLog(@"user %@ add contact %@", user, contact);
    NSMutableArray<DIMID *> *contacts = [_contactMap objectForKey:user.ID.address];
    if (contacts) {
        if ([contacts containsObject:contact]) {
            NSLog(@"contact %@ already exists, user: %@", contact, user.ID);
            return NO;
        } else {
            [contacts addObject:contact];
        }
    } else {
        contacts = [[NSMutableArray alloc] initWithCapacity:1];
        [contacts addObject:contact];
        [_contactMap setObject:contacts forKey:user.ID.address];
    }
    [self _storeContacts:contacts forUser:user];
    return YES;
}

- (BOOL)user:(DIMLocalUser *)user removeContact:(DIMID *)contact {
    NSLog(@"user %@ remove contact %@", user, contact);
    NSMutableArray<DIMID *> *contacts = [_contactMap objectForKey:user.ID.address];
    if (contacts) {
        if ([contacts containsObject:contact]) {
            [contacts removeObject:contact];
        } else {
            NSLog(@"contact %@ not exists, user: %@", contact, user.ID);
            return NO;
        }
    } else {
        NSLog(@"user %@ doesn't has contact yet", user.ID);
        return NO;
    }
    [self _storeContacts:contacts forUser:user];
    return YES;
}

- (BOOL)group:(DIMGroup *)group addMember:(DIMID *)member {
    NSArray<DIMID *> *members = group.members;
    if ([members containsObject:member]) {
        NSAssert(false, @"member already exists: %@, %@", member, group);
        return NO;
    }
    NSMutableArray *mArray = [members mutableCopy];
    [mArray addObject:member];
    return [self _storeMembers:mArray forGroup:group];
}

- (BOOL)group:(DIMGroup *)group removeMember:(DIMID *)member {
    NSArray<DIMID *> *members = group.members;
    if (![members containsObject:member]) {
        NSAssert(false, @"member not exists: %@, %@", member, group);
        return NO;
    }
    NSMutableArray *mArray = [members mutableCopy];
    [mArray removeObject:member];
    return [self _storeMembers:mArray forGroup:group];
}

@end
