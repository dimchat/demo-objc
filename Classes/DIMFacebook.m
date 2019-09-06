//
//  DIMFacebook.m
//  DIMClient
//
//  Created by Albert Moky on 2019/6/26.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMECCPrivateKey.h"
#import "MKMECCPublicKey.h"
#import "MKMAddressETH.h"
#import "MKMMetaETH.h"

#import "DIMSocialNetworkDatabase.h"

#import "DIMServer.h"

#import "DIMFacebook.h"

@interface DIMFacebook () {
    
    // delegates
    __weak __kindof id<DIMSocialNetworkDatabase> _database;
}

@end

@implementation DIMFacebook

SingletonImplementations(DIMFacebook, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        
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

- (nullable DIMID *)IDWithAddress:(DIMAddress *)address {
    return [_database IDWithAddress:address];
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
    meta = [_database metaForID:ID];
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
    return [_database profileForID:ID];
}

#pragma mark - MKMUserDataSource

- (nullable DIMPrivateKey *)privateKeyForSignatureOfUser:(DIMID *)user {
    DIMPrivateKey *key = [super privateKeyForSignatureOfUser:user];
    if (!key) {
        key = [_database privateKeyForSignatureOfUser:user];
    }
    return key;
}

- (nullable NSArray<DIMPrivateKey *> *)privateKeysForDecryptionOfUser:(DIMID *)user {
    NSArray<DIMPrivateKey *> *keys = [super privateKeysForDecryptionOfUser:user];
    if (keys.count == 0) {
        keys = [_database privateKeysForDecryptionOfUser:user];
    }
    return keys;
}

- (nullable NSArray<DIMID *> *)contactsOfUser:(DIMID *)user {
    NSArray<DIMID *> *contacts = [super contactsOfUser:user];
    if (contacts) {
        return contacts;
    }
    return [_database contactsOfUser:user];
}

#pragma mark - MKMGroupDataSource

- (nullable DIMID *)founderOfGroup:(DIMID *)group {
    DIMID *founder = [super founderOfGroup:group];
    if (founder) {
        return founder;
    }
    return [_database founderOfGroup:group];
}

- (nullable DIMID *)ownerOfGroup:(DIMID *)group {
    DIMID *owner = [super ownerOfGroup:group];
    if (owner) {
        return owner;
    }
    return [_database ownerOfGroup:group];
}

- (nullable NSArray<DIMID *> *)membersOfGroup:(DIMID *)group {
    NSArray<DIMID *> *members = [super membersOfGroup:group];
    if (members) {
        return members;
    }
    return [_database membersOfGroup:group];
}

@end

@implementation DIMFacebook (Storage)

- (BOOL)savePrivateKey:(DIMPrivateKey *)key forID:(DIMID *)ID {
    return [_database savePrivateKey:key forID:ID];
}

- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    return [_database saveMeta:meta forID:ID];
}

- (BOOL)saveProfile:(DIMProfile *)profile {
    return [_database saveProfile:profile];
}

- (BOOL)saveContacts:(NSArray *)contacts user:(DIMID *)user {
    return [_database saveContacts:contacts user:user];
}

- (BOOL)saveMembers:(NSArray *)members group:(DIMID *)group {
    return [_database saveMembers:members group:group];
}

@end

@implementation DIMFacebook (Relationship)

- (BOOL)user:(DIMLocalUser *)user addContact:(DIMID *)contact {
    NSLog(@"user %@ add contact %@", user, contact);
    NSArray<DIMID *> *contacts = [self contactsOfUser:user.ID];
    if (contacts) {
        if ([contacts containsObject:contact]) {
            NSLog(@"contact %@ already exists, user: %@", contact, user.ID);
            return NO;
        } else {
            NSMutableArray *mArray = [contacts mutableCopy];
            [mArray addObject:contact];
            contacts = mArray;
        }
    } else {
        NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:1];
        [mArray addObject:contact];
        contacts = mArray;
    }
    return [self saveContacts:contacts user:user.ID];
}

- (BOOL)user:(DIMLocalUser *)user removeContact:(DIMID *)contact {
    NSLog(@"user %@ remove contact %@", user, contact);
    NSArray<DIMID *> *contacts = [self contactsOfUser:user.ID];
    if (contacts) {
        if ([contacts containsObject:contact]) {
            NSMutableArray *mArray = [contacts mutableCopy];
            [mArray removeObject:contact];
            contacts = mArray;
        } else {
            NSLog(@"contact %@ not exists, user: %@", contact, user.ID);
            return NO;
        }
    } else {
        NSLog(@"user %@ doesn't has contact yet", user.ID);
        return NO;
    }
    return [self saveContacts:contacts user:user.ID];
}

- (BOOL)group:(DIMGroup *)group addMember:(DIMID *)member {
    NSArray<DIMID *> *members = group.members;
    if ([members containsObject:member]) {
        NSAssert(false, @"member already exists: %@, %@", member, group);
        return NO;
    }
    NSMutableArray *mArray = [members mutableCopy];
    [mArray addObject:member];
    members = mArray;
    return [self saveMembers:members group:group.ID];
}

- (BOOL)group:(DIMGroup *)group removeMember:(DIMID *)member {
    NSArray<DIMID *> *members = group.members;
    if (![members containsObject:member]) {
        NSAssert(false, @"member not exists: %@, %@", member, group);
        return NO;
    }
    NSMutableArray *mArray = [members mutableCopy];
    [mArray removeObject:member];
    members = mArray;
    return [self saveMembers:members group:group.ID];
}

@end
