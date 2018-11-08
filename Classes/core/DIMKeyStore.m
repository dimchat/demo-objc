//
//  DIMKeyStore.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSObject+JsON.h"

#import "DIMKeyStore.h"

static inline NSString *caches_directory(void) {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                NSUserDomainMask, YES);
    return paths.firstObject;
}

/**
 Get full filepath to Caches Directory

 @param ID - current user ID
 @param filename - "keystore_*.plist"
 @return "Library/Caches/{address}/keystore_*.plist"
 */
static inline NSString *full_filepath(const MKMID *ID, NSString *filename) {
    assert(ID.isValid);
    // base directory: Library/Caches/{address}
    NSString *dir = caches_directory();
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

SingletonImplementations(DIMKeyStore, sharedInstance)

- (void)dealloc {
    [self flush];
    //[super dealloc];
}

- (instancetype)init {
    if (self = [super init]) {
        _keysForContacts = [[KeysTable alloc] init];
        _keysFromContacts = [[KeysTable alloc] init];
        
        _keysForGroups = [[KeysTable alloc] init];
        _tablesFromGroups = [[NSMutableDictionary alloc] init];
        
        [self _loadKeyStoreFiles];
        _dirty = NO;
    }
    return self;
}

// inner function
- (BOOL)_loadKeyStoreFiles {
    NSString *path;
    
    NSDictionary *dict;
    id cKey;
    id obj;
    MKMID *cID;
    MKMSymmetricKey *PW;
    
    BOOL changed = NO;
    
    // keys from contacts
    path = full_filepath(_currentUser, DIM_KEYSTORE_CONTACTS_FILENAME);
    if (file_exists(path)) {
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
            [self setCipherKey:PW fromContact:cID];
        }
        changed = YES;
    }
    
    id gKey, eKey;
    MKMID *gID, *mID;
    KeysTable *table;
    
    // keys from group.members
    path = full_filepath(_currentUser, DIM_KEYSTORE_GROUPS_FILENAME);
    if (file_exists(path)) {
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
                [self setCipherKey:PW fromMember:mID inGroup:gID];
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
    path = full_filepath(_currentUser, DIM_KEYSTORE_CONTACTS_FILENAME);
    BOOL OK1 = [_keysFromContacts writeToFile:path atomically:YES];
    
    // keys from group.members
    path = full_filepath(_currentUser, DIM_KEYSTORE_GROUPS_FILENAME);
    BOOL OK2 = [_tablesFromGroups writeToFile:path atomically:YES];
    
    return OK1 && OK2;
}

- (BOOL)flush {
    return [self _saveKeyStoreFiles];
}

#pragma mark - Cipher key to encpryt message for contact

- (MKMSymmetricKey *)cipherKeyForContact:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
    return [_keysForContacts objectForKey:ID.address];
}

- (void)setCipherKey:(MKMSymmetricKey *)key
          forContact:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
    [_keysForContacts setObject:key forKey:ID.address];
}

#pragma mark - Cipher key from contact to decrypt message

- (MKMSymmetricKey *)cipherKeyFromContact:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
    return [_keysFromContacts objectForKey:ID.address];
}

- (void)setCipherKey:(MKMSymmetricKey *)key
         fromContact:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
    [_keysFromContacts setObject:key forKey:ID.address];
    _dirty = YES;
}

#pragma mark - Cipher key to encrypt message for all group members

- (MKMSymmetricKey *)cipherKeyForGroup:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Group, @"ID error");
    return [_keysForGroups objectForKey:ID.address];
}

- (void)setCipherKey:(MKMSymmetricKey *)key
            forGroup:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Group, @"ID error");
    [_keysForGroups setObject:key forKey:ID.address];
}

#pragma mark - Cipher key from a member in the group to decrypt message

- (MKMSymmetricKey *)cipherKeyFromMember:(const MKMID *)ID
                                 inGroup:(const MKMID *)group {
    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
    NSAssert(group.address.network == MKMNetwork_Group, @"group ID error");
    KeysTable *table = [_tablesFromGroups objectForKey:group.address];
    return [table objectForKey:ID.address];
}

- (void)setCipherKey:(MKMSymmetricKey *)key
          fromMember:(const MKMID *)ID
             inGroup:(const MKMID *)group {
    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
    NSAssert(group.address.network == MKMNetwork_Group, @"group ID error");
    KeysTable *table = [_tablesFromGroups objectForKey:group.address];
    if (!table) {
        table = [[KeysTable alloc] init];
        [_tablesFromGroups setObject:table forKey:group.address];
    }
    [table setObject:key forKey:ID.address];
    _dirty = YES;
}

#pragma mark - Private key encrpyted by a password for user

- (NSData *)privateKeyStoredForUser:(const MKMUser *)user
                         passphrase:(const MKMSymmetricKey *)scKey {
    MKMPrivateKey *SK = [user privateKey];
    NSData *data = [SK jsonData];
    return [scKey encrypt:data];
}

@end
