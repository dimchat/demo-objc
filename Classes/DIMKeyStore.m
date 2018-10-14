//
//  DIMKeyStore.m
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMKeyStore.h"

typedef NSMutableDictionary<const MKMID *, MKMSymmetricKey *> KeysTable;

@interface DIMKeyStore () {
    
    KeysTable *_keysForContacts;
    KeysTable *_keysFromContacts;
    
    KeysTable *_keysForGroups;
    NSMutableDictionary<const MKMID *, KeysTable *> *_tablesFromGroups;
}

@end

@implementation DIMKeyStore

static DIMKeyStore *s_sharedInstance = nil;

+ (instancetype)sharedInstance {
    if (!s_sharedInstance) {
        s_sharedInstance = [[self alloc] init];
    }
    return s_sharedInstance;
}

+ (instancetype)alloc {
    NSAssert(!s_sharedInstance, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        _keysForContacts = [[KeysTable alloc] init];
        _keysFromContacts = [[KeysTable alloc] init];
        
        _keysForGroups = [[KeysTable alloc] init];
        _tablesFromGroups = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Cipher key to encpryt message for contact

- (MKMSymmetricKey *)cipherKeyForContact:(const MKMContact *)contact {
    return [_keysForContacts objectForKey:contact.ID];
}

- (void)setCipherKey:(MKMSymmetricKey *)key
          forContact:(const MKMContact *)contact {
    [_keysForContacts setObject:key forKey:contact.ID];
}

#pragma mark - Cipher key from contact to decrypt message

- (MKMSymmetricKey *)cipherKeyFromContact:(const MKMContact *)contact {
    return [_keysFromContacts objectForKey:contact.ID];
}

- (void)setCipherKey:(MKMSymmetricKey *)key
         fromContact:(const MKMContact *)contact {
    [_keysFromContacts setObject:key forKey:contact.ID];
}

#pragma mark - Cipher key to encrypt message for all group members

- (MKMSymmetricKey *)cipherKeyForGroup:(const MKMGroup *)group {
    return [_keysForGroups objectForKey:group.ID];
}

- (void)setCipherKey:(MKMSymmetricKey *)key
            forGroup:(const MKMGroup *)group {
    [_keysForGroups setObject:key forKey:group.ID];
}

#pragma mark - Cipher key from a member in the group to decrypt message

- (MKMSymmetricKey *)cipherKeyFromMember:(const MKMContact *)member
                                 inGroup:(const MKMGroup *)group {
    KeysTable *table = [_tablesFromGroups objectForKey:group.ID];
    return [table objectForKey:member.ID];
}

- (void)setCipherKey:(MKMSymmetricKey *)key
          fromMember:(const MKMContact *)member
             inGroup:(const MKMGroup *)group {
    KeysTable *table = [_tablesFromGroups objectForKey:group.ID];
    if (!table) {
        table = [[KeysTable alloc] init];
        [_tablesFromGroups setObject:table forKey:group.ID];
    }
    [table setObject:key forKey:member.ID];
}

#pragma mark - Private key encrpyted by a password for user

- (NSData *)privateKeyStoredForUser:(const MKMUser *)user
                         passphrase:(const MKMSymmetricKey *)scKey {
    MKMPrivateKey *SK = [user privateKey];
    NSData *data = [SK jsonData];
    return [scKey encrypt:data];
}

@end
