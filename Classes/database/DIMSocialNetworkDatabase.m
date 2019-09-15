//
//  DIMSocialNetworkDatabase.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMAddressNameTable.h"
#import "DIMMetaTable.h"
#import "DIMProfileTable.h"
#import "DIMUserTable.h"
#import "DIMGroupTable.h"

#import "DIMSocialNetworkDatabase.h"

@interface DIMSocialNetworkDatabase () {
    
    DIMAddressNameTable *_ansTable;
    DIMMetaTable *_metaTable;
    DIMProfileTable *_profileTable;
    DIMUserTable *_userTable;
    DIMGroupTable *_groupTable;
}

@end

@implementation DIMSocialNetworkDatabase

- (instancetype)init {
    if (self = [super init]) {
        _ansTable = [[DIMAddressNameTable alloc] init];
        _metaTable = [[DIMMetaTable alloc] init];
        _profileTable = [[DIMProfileTable alloc] init];
        _userTable = [[DIMUserTable alloc] init];
        _groupTable = [[DIMGroupTable alloc] init];
    }
    return self;
}

- (nullable DIMID *)IDWithAddress:(DIMAddress *)address {
    return [_metaTable IDWithAddress:address];
}

- (BOOL)saveANSRecord:(DIMID *)ID forName:(NSString *)name {
    return [_ansTable saveRecord:ID forName:name];
}

- (DIMID *)ansRecordForName:(NSString *)name {
    return [_ansTable recordForName:name];
}

- (NSArray<DIMID *> *)namesWithANSRecord:(NSString *)ID {
    return [_ansTable namesWithRecord:ID];
}

- (BOOL)savePrivateKey:(DIMPrivateKey *)key forID:(DIMID *)ID {
    return [key saveKeyWithIdentifier:ID.address];
}

- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    return [_metaTable saveMeta:meta forID:ID];
}

- (BOOL)saveProfile:(DIMProfile *)profile {
    return [_profileTable saveProfile:profile];
}

- (nullable NSArray<DIMID *> *)allUsers {
    return [_userTable allUsers];
}

- (BOOL)saveUsers:(NSArray<DIMID *> *)list {
    return [_userTable saveUsers:list];
}

- (BOOL)saveUser:(DIMID *)user {
    NSMutableArray<DIMID *> *list = (NSMutableArray<DIMID *> *)[_userTable allUsers];
    NSAssert(list, @"would not happen");
    if ([list containsObject:user]) {
        //NSAssert(false, @"user already exists: %@", user);
        return YES;
    }
    [list addObject:user];
    return [self saveUsers:list];
}

- (BOOL)removeUser:(DIMID *)user {
    NSMutableArray<DIMID *> *list = (NSMutableArray<DIMID *> *)[_userTable allUsers];
    NSAssert(list, @"would not happen");
    if (![list containsObject:user]) {
        //NSAssert(false, @"user not exists: %@", user);
        return YES;
    }
    [list removeObject:user];
    return [self saveUsers:list];
}

- (BOOL)saveContacts:(NSArray *)contacts user:(DIMID *)user {
    return [_userTable saveContacts:contacts user:user];
}

- (BOOL)saveMembers:(NSArray *)members group:(DIMID *)group {
    return [_groupTable saveMembers:members group:group];
}

#pragma mark -

- (nullable DIMPrivateKey *)privateKeyForSignatureOfUser:(DIMID *)user {
    return [DIMPrivateKey loadKeyWithIdentifier:user.address];
}

- (nullable NSArray<DIMPrivateKey *> *)privateKeysForDecryptionOfUser:(DIMID *)user {
    DIMPrivateKey *key = [DIMPrivateKey loadKeyWithIdentifier:user.address];
    return [[NSArray alloc] initWithObjects:key, nil];
}

- (nullable DIMMeta *)metaForID:(DIMID *)ID {
    return [_metaTable metaForID:ID];
}

- (nullable __kindof DIMProfile *)profileForID:(DIMID *)ID {
    return [_profileTable profileForID:ID];
}

- (nullable NSArray<DIMID *> *)contactsOfUser:(DIMID *)user {
    return [_userTable contactsOfUser:user];
}

- (nullable DIMID *)founderOfGroup:(DIMID *)group {
    return [_groupTable founderOfGroup:group];
}

- (nullable DIMID *)ownerOfGroup:(DIMID *)group {
    return [_groupTable ownerOfGroup:group];
}

- (nullable NSArray<DIMID *> *)membersOfGroup:(DIMID *)group {
    return [_groupTable membersOfGroup:group];
}

@end
