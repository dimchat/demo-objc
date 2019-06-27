//
//  DIMFacebook.m
//  DIMClient
//
//  Created by Albert Moky on 2019/6/26.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSDictionary+Binary.h"

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
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
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

- (nullable DIMMeta *)loadMetaForID:(DIMID *)ID {
    NSString *path = meta_filepath(ID, NO);
    if (file_exists(path)) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        return MKMMetaFromDictionary(dict);
    }
    return nil;
}

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
    // check default directary
    NSString *path = meta_filepath(ID, YES);
    if (file_exists(path)) {
        // no need to update meta file
        return YES;
    }
    return [meta writeToBinaryFile:path];
}

- (BOOL)verifyProfile:(DIMProfile *)profile {
    DIMID *ID = profile.ID;
    DIMPublicKey *key = nil;
    // check signer
    if (MKMNetwork_IsCommunicator(ID.type)) {
        // verify with meta.key
        DIMMeta *meta = [self metaForID:ID];
        key = meta.key;
    } else if (MKMNetwork_IsGroup(ID.type)) {
        // verify with group owner's meta.key
        DIMGroup *group = DIMGroupWithID(ID);
        DIMMeta *meta = [self metaForID:group.owner];
        key = meta.key;
    }
    return [profile verify:key];
}

- (DIMProfile *)profileForID:(DIMID *)ID {
    DIMProfile *profile = [super profileForID:ID];
    if (profile && [self verifyProfile:profile]) {
        // signature correct
        return profile;
    }
    // profile error
    return profile;
}

#pragma mark - DIMBarrackDelegate

- (nullable DIMAccount *)accountWithID:(DIMID *)ID {
    DIMAccount *account = [super accountWithID:ID];
    if (account) {
        return account;
    }
    // check meta
    DIMMeta *meta = DIMMetaForID(ID);
    if (!meta) {
        NSLog(@"meta not found: %@", ID);
    }
    // create it with type
    if (MKMNetwork_IsStation(ID.type)) {
        account = [[DIMServer alloc] initWithID:ID];
    } else if (MKMNetwork_IsPerson(ID.type)) {
        account = [[DIMAccount alloc] initWithID:ID];
    } else {
        NSAssert(false, @"account error: %@", ID);
    }
    [self cacheAccount:account];
    return account;
}

- (nullable DIMUser *)userWithID:(DIMID *)ID {
    DIMUser *user = [super userWithID:ID];
    if (user) {
        return user;
    }
    // check meta
    DIMMeta *meta = DIMMetaForID(ID);
    if (!meta) {
        NSLog(@"meta not found: %@", ID);
    }
    // TODO: check private key
    
    // create it with type
    if (MKMNetwork_IsPerson(ID.type)) {
        user = [[DIMUser alloc] initWithID:ID];
    } else {
        NSAssert(false, @"user error: %@", ID);
    }
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
    }
    // create it with type
    if (ID.type == MKMNetwork_Polylogue) {
        group = [[DIMPolylogue alloc] initWithID:ID];
    } else if (ID.type == MKMNetwork_Chatroom) {
        group = [[DIMChatroom alloc] initWithID:ID];
    } else {
        NSAssert(false, @"group error: %@", ID);
    }
    [self cacheGroup:group];
    return group;
}

@end
