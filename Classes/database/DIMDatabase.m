//
//  DIMDatabase.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMMetaTable.h"
#import "DIMProfileTable.h"
#import "DIMContactTable.h"
#import "DIMGroupTable.h"

#import "DIMDatabase.h"

@interface DIMDatabase () {
    
    DIMMetaTable *_metaTable;
    DIMProfileTable *_profileTable;
    DIMContactTable *_contactTable;
    DIMGroupTable *_groupTable;
}

@end

@implementation DIMDatabase

SingletonImplementations(DIMDatabase, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _metaTable = [[DIMMetaTable alloc] init];
        _profileTable = [[DIMProfileTable alloc] init];
        _contactTable = [[DIMContactTable alloc] init];
        _groupTable = [[DIMGroupTable alloc] init];
    }
    return self;
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

- (BOOL)saveContacts:(NSArray *)contacts user:(DIMID *)user {
    return [_contactTable saveContacts:contacts user:user];
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
    return [_contactTable contactsOfUser:user];
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
