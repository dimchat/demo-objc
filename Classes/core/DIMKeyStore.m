//
//  DIMKeyStore.m
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMKeyStore.h"

@interface DIMKeyStore () {
    
    NSMutableDictionary<const MKMID *, MKMSymmetricKey *> *_passphraseTable;
    
    NSMutableDictionary<const MKMID *, MKMPrivateKey *> *_privateKeyTable;
    NSMutableDictionary<const MKMID *, MKMPublicKey *> *_publicKeyTable;
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
    
    MKMPrivateKey *SK;
    MKMPublicKey *PK;
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

- (MKMPublicKey *)publicKeyForContact:(const MKMContact *)contact {
    MKMID *ID = contact.ID;
    MKMPublicKey *PK = [_publicKeyTable objectForKey:ID];
    if (!PK) {
        // get from entity manager
        MKMEntityManager *eman = [MKMEntityManager sharedInstance];
        PK = [eman metaWithID:ID].key;
        if (PK) {
            [_publicKeyTable setObject:PK forKey:ID];
        }
    }
    return PK;
}

- (MKMPrivateKey *)privateKeyForUser:(const MKMUser *)user {
    MKMID *ID = user.ID;
    return [_privateKeyTable objectForKey:ID];
}

- (void)setPrivateKey:(MKMPrivateKey *)SK
              forUser:(const MKMUser *)user {
    NSAssert(user.status == MKMAccountStatusRegistered, @"status error");
    MKMID *ID = user.ID;
    [_privateKeyTable setObject:SK forKey:ID];
}

- (MKMSymmetricKey *)passphraseForEntity:(const MKMEntity *)entity {
    MKMID *ID = entity.ID;
    MKMSymmetricKey *scKey = [_passphraseTable objectForKey:ID];
    if (!scKey) {
        // generate a new one
        NSNumber *num = @(arc4random());
        NSDictionary *dict = @{@"algorithm": @"AES",
                               @"passphrase":[num stringValue]
                               };
        scKey = [[MKMSymmetricKey alloc] initWithAlgorithm:@"AES"
                                                   keyInfo:dict];
        [_passphraseTable setObject:scKey forKey:ID];
    }
    return scKey;
}

- (void)setPassphrase:(MKMSymmetricKey *)PW
            forEntity:(const MKMEntity *)entity {
    MKMID *ID = entity.ID;
    [_passphraseTable setObject:PW forKey:ID];
}

- (NSData *)privateKeyStoredForUser:(const MKMUser *)user
                         passphrase:(const MKMSymmetricKey *)scKey {
    MKMPrivateKey *SK = [self privateKeyForUser:user];
    NSData *data = [SK jsonData];
    return [scKey encrypt:data];
}

@end
