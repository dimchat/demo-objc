//
//  DIMFacebook.m
//  DIMClient
//
//  Created by Albert Moky on 2019/6/26.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSDictionary+Binary.h"

#import "MKMECCPrivateKey.h"
#import "MKMECCPublicKey.h"
#import "MKMAddressETH.h"
#import "MKMMetaETH.h"

#import "DIMServer.h"

#import "DIMFacebook.h"

static inline NSString *document_directory(void) {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                NSUserDomainMask, YES);
    return paths.firstObject;
}

static inline void make_dirs(NSString *dir) {
    // check base directory exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir isDirectory:nil]) {
        NSError *error = nil;
        // make sure directory exists
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES
                       attributes:nil error:&error];
        assert(!error);
    }
}

static inline BOOL file_exists(NSString *path) {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:path];
}

// default: "Documents/.mkm"
static NSString *s_directory = nil;
static inline NSString *base_directory(void) {
    SingletonDispatchOnce(^{
        if (s_directory == nil) {
            NSString *dir = document_directory();
            dir = [dir stringByAppendingPathComponent:@".mkm"];
            s_directory = dir;
        }
    });
    return s_directory;
}

/**
 *  Get meta filepath in Documents Directory
 *
 * @param ID - entity ID
 * @return "Documents/.mkm/{address}/meta.plist"
 */
static inline NSString *meta_filepath(DIMID *ID, BOOL autoCreate) {
    NSString *dir = base_directory();
    dir = [dir stringByAppendingPathComponent:ID.address];
    // check base directory exists
    if (autoCreate && !file_exists(dir)) {
        // make sure directory exists
        make_dirs(dir);
    }
    return [dir stringByAppendingPathComponent:@"meta.plist"];
}

@implementation DIMFacebook

SingletonImplementations(DIMFacebook, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        // register new asymmetric cryptography key classes
        [MKMPrivateKey registerClass:[MKMECCPrivateKey class] forAlgorithm:ACAlgorithmECC];
        [MKMPublicKey registerClass:[MKMECCPublicKey class] forAlgorithm:ACAlgorithmECC];
        
        // register new address classes
        [MKMAddress registerClass:[MKMAddressETH class]];
        
        // register new meta classes
        [MKMMeta registerClass:[MKMMetaBTC class] forVersion:MKMMetaVersion_BTC];
        [MKMMeta registerClass:[MKMMetaBTC class] forVersion:MKMMetaVersion_ExBTC];
        [MKMMeta registerClass:[MKMMetaETH class] forVersion:MKMMetaVersion_ETH];
        [MKMMeta registerClass:[MKMMetaETH class] forVersion:MKMMetaVersion_ExETH];
    }
    return self;
}

- (BOOL)verifyProfile:(DIMProfile *)profile {
    if (!profile) {
        return NO;
    } else if ([profile isValid]) {
        // already verified
        return YES;
    }
    DIMID *ID = profile.ID;
    NSAssert([ID isValid], @"Invalid ID: %@", ID);
    DIMMeta *meta = nil;
    // check signer
    if (MKMNetwork_IsCommunicator(ID.type)) {
        // verify with account's meta.key
        meta = [self metaForID:ID];
    } else if (MKMNetwork_IsGroup(ID.type)) {
        // verify with group owner's meta.key
        DIMGroup *group = DIMGroupWithID(ID);
        DIMID *owner = group.owner;
        if ([owner isValid]) {
            meta = [self metaForID:owner];
        }
    }
    return [profile verify:meta.key];
}

- (nullable DIMMeta *)loadMetaForID:(DIMID *)ID {
    NSString *path = meta_filepath(ID, NO);
    if (file_exists(path)) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        return MKMMetaFromDictionary(dict);
    }
    return nil;
}

#pragma mark - DIMEntityDataSource

- (nullable DIMMeta *)metaForID:(DIMID *)ID {
    DIMMeta *meta = [super metaForID:ID];
    if (meta) {
        return meta;
    }
    // load from local storage
    meta = [self loadMetaForID:ID];
    if ([self cacheMeta:meta forID:ID]) {
        return meta;
    } else {
        NSAssert(!meta, @"meta error: %@ -> %@", ID, meta);
        return nil;
    }
}

- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    if ([super saveMeta:meta forID:ID]) {
        return YES;
    }
    // check whether match ID
    if (![meta matchID:ID]) {
        NSAssert(false, @"meta not match ID: %@, %@", ID, meta);
        return NO;
    }
    // check default directory
    NSString *path = meta_filepath(ID, YES);
    if (file_exists(path)) {
        // no need to update meta file
        return YES;
    }
    return [meta writeToBinaryFile:path];
}

- (DIMProfile *)profileForID:(DIMID *)ID {
    DIMProfile *profile = [super profileForID:ID];
    if (!profile || [profile isValid]) {
        // already verified?
        return profile;
    }
    if ([self verifyProfile:profile]) {
        // signature correct
        return profile;
    }
    // profile error?
    return profile;
}

#pragma mark - DIMSocialNetworkDataSource

- (nullable DIMAccount *)accountWithID:(DIMID *)ID {
    DIMAccount *account = [super accountWithID:ID];
    if (account) {
        return account;
    }
    // check meta
    DIMMeta *meta = DIMMetaForID(ID);
    if (!meta) {
        NSLog(@"meta not found: %@", ID);
        return nil;
    }
    // create it with type
    if (MKMNetwork_IsStation(ID.type)) {
        account = [[DIMServer alloc] initWithID:ID];
    } else if (MKMNetwork_IsPerson(ID.type)) {
        account = [[DIMAccount alloc] initWithID:ID];
    }
    NSAssert(account, @"account error: %@", ID);
    [self cacheAccount:account];
    return account;
}

- (nullable DIMUser *)userWithID:(DIMID *)ID {
    if (!MKMNetwork_IsPerson(ID.type)) {
        return nil;
    }
    DIMUser *user = [super userWithID:ID];
    if (user) {
        return user;
    }
    // check meta and private key
    DIMMeta *meta = DIMMetaForID(ID);
    DIMPrivateKey *key = [self privateKeyForSignatureOfUser:ID];
    if (!meta || !key) {
        NSLog(@"meta/private key not found: %@", ID);
        return nil;
    }
    // create it
    user = [[DIMUser alloc] initWithID:ID];
    [self cacheUser:user];
    return user;
}

- (nullable DIMGroup *)groupWithID:(DIMID *)ID {
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
    }
    NSAssert(group, @"group error: %@", ID);
    [self cacheGroup:group];
    return group;
}

@end
