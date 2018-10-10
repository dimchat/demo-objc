//
//  MKMKeyStore.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMSymmetricKey.h"
#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMEntity.h"
#import "MKMUser.h"
#import "MKMContact.h"

#import "MKMKeyStore.h"

@interface MKMKeyStore () {
    
    NSMutableDictionary<const MKMID *, const MKMSymmetricKey *> *_passphraseTable;
    
    NSMutableDictionary<const MKMID *, const MKMPrivateKey *> *_privateKeyTable;
    NSMutableDictionary<const MKMID *, const MKMPublicKey *> *_publicKeyTable;
}

@end

@implementation MKMKeyStore

static MKMKeyStore *s_sharedStore = nil;

+ (instancetype)sharedStore {
    if (!s_sharedStore) {
        s_sharedStore = [[self alloc] init];
    }
    return s_sharedStore;
}

+ (instancetype)alloc {
    NSAssert(!s_sharedStore, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        _passphraseTable = [[NSMutableDictionary alloc] init];
        
        _privateKeyTable = [[NSMutableDictionary alloc] init];
        _publicKeyTable = [[NSMutableDictionary alloc] init];
        
        // Immortals
        [self loadEntityKeysFromFile:@"mkm_hulk"];
        [self loadEntityKeysFromFile:@"mkm_moki"];
    }
    return self;
}

- (BOOL)loadEntityKeysFromFile:(NSString *)filename {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path;
    NSDictionary *dict;
    MKMID *ID;
    
    path = [bundle pathForResource:filename ofType:@"plist"];
    if (![fm fileExistsAtPath:path]) {
        NSAssert(false, @"cannot load: %@", path);
        return NO;
    }
    
    // ID
    dict = [NSDictionary dictionaryWithContentsOfFile:path];
    ID = [dict objectForKey:@"ID"];
    if (!ID) {
        NSAssert(false, @"ID not foun: %@", path);
        return NO;
    }
    ID = [MKMID IDWithID:ID];
    
    // load keys
    NSDictionary *keys;
    keys = [dict objectForKey:@"keys"];
    if (!keys) {
        NSAssert(false, @"keys not found: %@", path);
        return NO;
    }
    
    const MKMPrivateKey *SK;
    const MKMPublicKey *PK;
    NSString *algor;
    
    // public key
    NSDictionary *pub = [keys objectForKey:@"publicKey"];
    algor = [pub objectForKey:@"algorithm"];
    PK = [[MKMPublicKey alloc] initWithAlgorithm:algor keyInfo:pub];
    // private key
    NSDictionary *pri = [keys objectForKey:@"privateKey"];
    algor = [pub objectForKey:@"algorithm"];
    SK = [[MKMPrivateKey alloc] initWithAlgorithm:algor keyInfo:pri];
    
    if (PK) {
        NSAssert([PK isMatch:SK], @"keys error");
    } else {
        PK = SK.publicKey;
    }
    
    if (SK) {
        [_privateKeyTable setObject:SK forKey:ID];
    }
    if (PK) {
        [_publicKeyTable setObject:PK forKey:ID];
    }
    
    return YES;
}

#pragma mark -

- (const MKMPublicKey *)publicKeyForContact:(const MKMContact *)contact {
    const MKMID *ID = contact.ID;
    return [_publicKeyTable objectForKey:ID];
}

- (void)setPublicKey:(const MKMPublicKey *)PK
          forContact:(const MKMContact *)contact {
    const MKMID *ID = contact.ID;
    [_publicKeyTable setObject:PK forKey:ID];
}

- (const MKMPrivateKey *)privateKeyForUser:(const MKMUser *)user {
    const MKMID *ID = user.ID;
    return [_privateKeyTable objectForKey:ID];
}

- (void)setPrivateKey:(const MKMPrivateKey *)SK
              forUser:(const MKMUser *)user {
    const MKMID *ID = user.ID;
    [_privateKeyTable setObject:SK forKey:ID];
}

- (const MKMSymmetricKey *)passphraseForEntity:(const MKMEntity *)entity {
    const MKMID *ID = entity.ID;
    const MKMSymmetricKey *scKey = [_passphraseTable objectForKey:ID];
    if (!scKey) {
        NSNumber *num = @(arc4random());
        NSDictionary *dict = @{@"algorithm": @"AES",
                               @"passphrase":[num stringValue]};
        scKey = [[MKMSymmetricKey alloc] initWithAlgorithm:@"AES" keyInfo:dict];
    }
    return scKey;
}

- (void)setPassphrase:(const MKMSymmetricKey *)PW
            forEntity:(const MKMEntity *)entity {
    const MKMID *ID = entity.ID;
    [_passphraseTable setObject:PW forKey:ID];
}

- (const NSData *)privateKeyStoredForUser:(const MKMUser *)user
                               passphrase:(const MKMSymmetricKey *)scKey {
    const MKMPrivateKey *SK = [self privateKeyForUser:user];
    const NSData *data = [SK jsonData];
    return [scKey encrypt:data];
}

@end
