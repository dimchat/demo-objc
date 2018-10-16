//
//  DIMKeyStore.m
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMKeyStore.h"

typedef NSMutableDictionary<const MKMAddress *, MKMSymmetricKey *> KeysTable;

@interface DIMKeyStore () {
    
    KeysTable *_keysForContacts;
    KeysTable *_keysFromContacts;
    
    KeysTable *_keysForGroups;
    NSMutableDictionary<const MKMAddress *, KeysTable *> *_tablesFromGroups;
}

@property (nonatomic, getter=isDirty) BOOL dirty;

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
        
        _dirty = NO;
        [self _loadKeyStoreFiles];
    }
    return self;
}

// inner function
- (NSString *)_dataFilePath:(NSString *)filename {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                NSUserDomainMask, YES);
    NSString *docs = paths.firstObject;
    return [docs stringByAppendingPathComponent:filename];
}

// inner function
- (BOOL)_loadKeyStoreFiles {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path;
    
    NSDictionary *dict;
    id cKey;
    id obj;
    MKMID *cID;
    MKMSymmetricKey *PW;
    
    BOOL changed = NO;
    
    // keys from contacts
    path = [self _dataFilePath:DIM_KEYSTORE_CONTACTS_FILENAME];
    if ([fm fileExistsAtPath:path]) {
        // load keys from contact
        dict = [NSDictionary dictionaryWithContentsOfFile:path];
        for (cKey in dict) {
            obj = [dict objectForKey:cKey];
            // ID
            cID = [MKMID IDWithID:cKey];
            NSAssert(cID.address.network == MKMNetwork_Main, @"error");
            // key
            PW = [MKMSymmetricKey keyWithKey:obj];
            // update keys table
            [self _setCipherKey:PW fromContactByAddress:cID.address];
        }
        changed = YES;
    }
    
    id gKey, eKey;
    MKMID *gID, *mID;
    KeysTable *table;
    
    // keys from group.members
    path = [self _dataFilePath:DIM_KEYSTORE_GROUPS_FILENAME];
    if ([fm fileExistsAtPath:path]) {
        // load keys from contact
        dict = [NSDictionary dictionaryWithContentsOfFile:path];
        for (gKey in dict) {
            obj = [dict objectForKey:gKey];
            // group ID
            gID = [MKMID IDWithID:gKey];
            NSAssert(gID.address.network == MKMNetwork_Group, @"error");
            // table
            table = obj;
            for (eKey in table) {
                obj = [table objectForKey:eKey];
                // member ID
                mID = [MKMID IDWithID:eKey];
                NSAssert(mID.address.network == MKMNetwork_Main, @"error");
                // key
                PW = [MKMSymmetricKey keyWithKey:obj];
                // update keys table
                [self _setCipherKey:PW
                fromMemberByAddress:mID.address
                   inGroupByAddress:gID.address];
            }
        }
        changed = YES;
    }
    
    return changed;
}

// inner function
- (BOOL)_saveKeyStoreFiles {
    if (!_dirty) {
        return NO;
    }
    NSString *path;
    
    // keys from contacts
    path = [self _dataFilePath:DIM_KEYSTORE_CONTACTS_FILENAME];
    BOOL OK1 = [_keysFromContacts writeToFile:path atomically:YES];
    
    // keys from group.members
    path = [self _dataFilePath:DIM_KEYSTORE_GROUPS_FILENAME];
    BOOL OK2 = [_tablesFromGroups writeToFile:path atomically:YES];
    
    return OK1 && OK2;
}

- (BOOL)flush {
    return [self _saveKeyStoreFiles];
}

#pragma mark - Cipher key to encpryt message for contact

- (MKMSymmetricKey *)cipherKeyForContact:(const MKMContact *)contact {
    return [_keysForContacts objectForKey:contact.ID.address];
}

- (void)setCipherKey:(MKMSymmetricKey *)key
          forContact:(const MKMContact *)contact {
    [_keysForContacts setObject:key forKey:contact.ID.address];
}

#pragma mark - Cipher key from contact to decrypt message

- (MKMSymmetricKey *)cipherKeyFromContact:(const MKMContact *)contact {
    return [_keysFromContacts objectForKey:contact.ID.address];
}

- (void)setCipherKey:(MKMSymmetricKey *)key
         fromContact:(const MKMContact *)contact {
    [_keysFromContacts setObject:key forKey:contact.ID.address];
    _dirty = YES;
}

// inner function
- (void)_setCipherKey:(MKMSymmetricKey *)key
 fromContactByAddress:(const MKMAddress *)address {
    [_keysFromContacts setObject:key forKey:address];
}

#pragma mark - Cipher key to encrypt message for all group members

- (MKMSymmetricKey *)cipherKeyForGroup:(const MKMGroup *)group {
    return [_keysForGroups objectForKey:group.ID.address];
}

- (void)setCipherKey:(MKMSymmetricKey *)key
            forGroup:(const MKMGroup *)group {
    [_keysForGroups setObject:key forKey:group.ID.address];
}

#pragma mark - Cipher key from a member in the group to decrypt message

- (MKMSymmetricKey *)cipherKeyFromMember:(const MKMEntity *)member
                                 inGroup:(const MKMGroup *)group {
    KeysTable *table = [_tablesFromGroups objectForKey:group.ID.address];
    return [table objectForKey:member.ID.address];
}

- (void)setCipherKey:(MKMSymmetricKey *)key
          fromMember:(const MKMEntity *)member
             inGroup:(const MKMGroup *)group {
    KeysTable *keysFromMembers;
    keysFromMembers = [_tablesFromGroups objectForKey:group.ID.address];
    if (!keysFromMembers) {
        keysFromMembers = [[KeysTable alloc] init];
        [_tablesFromGroups setObject:keysFromMembers
                              forKey:group.ID.address];
    }
    [keysFromMembers setObject:key forKey:member.ID.address];
    _dirty = YES;
}

// inner function
- (void)_setCipherKey:(MKMSymmetricKey *)key
  fromMemberByAddress:(const MKMAddress *)mAddr
     inGroupByAddress:(const MKMAddress *)gAddr {
    KeysTable *table = [_tablesFromGroups objectForKey:gAddr];
    if (!table) {
        table = [[KeysTable alloc] init];
        [_tablesFromGroups setObject:table forKey:gAddr];
    }
    [table setObject:key forKey:mAddr];
}

#pragma mark - Private key encrpyted by a password for user

- (NSData *)privateKeyStoredForUser:(const MKMUser *)user
                         passphrase:(const MKMSymmetricKey *)scKey {
    MKMPrivateKey *SK = [user privateKey];
    NSData *data = [SK jsonData];
    return [scKey encrypt:data];
}

@end
