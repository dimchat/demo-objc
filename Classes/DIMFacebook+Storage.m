//
//  DIMFacebook+Storage.m
//  DIMClient
//
//  Created by Albert Moky on 2019/8/13.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSDictionary+Binary.h"

#import "DIMFacebook+Storage.h"

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

// default: "Documents/.mkm/{address}"
static inline NSString *user_directory(DIMID *ID, BOOL autoCreate) {
    NSString *dir = base_directory();
    dir = [dir stringByAppendingPathComponent:ID.address];
    // check base directory exists
    if (autoCreate && !file_exists(dir)) {
        // make sure directory exists
        make_dirs(dir);
    }
    return dir;
}

/**
 *  Get meta filepath in Documents Directory
 *
 * @param ID - entity ID
 * @return "Documents/.mkm/{address}/meta.plist"
 */
static inline NSString *meta_filepath(DIMID *ID, BOOL autoCreate) {
    NSString *dir = user_directory(ID, autoCreate);
    return [dir stringByAppendingPathComponent:@"meta.plist"];
}

/**
 *  Get profile filepath in Documents Directory
 *
 * @param ID - entity ID
 * @return "Documents/.mkm/{address}/profile.plist"
 */
static inline NSString *profile_filepath(DIMID *ID, BOOL autoCreate) {
    NSString *dir = user_directory(ID, autoCreate);
    return [dir stringByAppendingPathComponent:@"profile.plist"];
}

/**
 *  Get contacts filepath in Documents Directory
 *
 * @param user - user ID
 * @return "Documents/.mkm/{address}/contacts.plist"
 */
static inline NSString *contacts_filepath(DIMID *user, BOOL autoCreate) {
    NSString *dir = user_directory(user, autoCreate);
    return [dir stringByAppendingPathComponent:@"contacts.plist"];
}

/**
 *  Get group members filepath in Documents Directory
 *
 * @param group - group ID
 * @return "Documents/.mkm/{address}/members.plist"
 */
static inline NSString *members_filepath(DIMID *group, BOOL autoCreate) {
    NSString *dir = user_directory(group, autoCreate);
    return [dir stringByAppendingPathComponent:@"members.plist"];
}

@implementation DIMFacebook (Storage)

- (nullable DIMMeta *)loadMetaForID:(DIMID *)ID {
    NSString *path = meta_filepath(ID, NO);
    if (!file_exists(path)) {
        NSLog(@"meta not found: %@", path);
        return nil;
    }
    //NSLog(@"loading meta from: %@", path);
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    return MKMMetaFromDictionary(dict);
}

- (nullable __kindof DIMProfile *)loadProfileForID:(DIMID *)ID {
    NSString *path = profile_filepath(ID, NO);
    if (!file_exists(path)) {
        NSLog(@"profile not found: %@", path);
        return nil;
    }
    //NSLog(@"loading profile from %@", path);
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    return MKMProfileFromDictionary(dict);
}

- (nullable NSArray<DIMID *> *)loadContactsForUser:(DIMID *)user {
    NSString *path = contacts_filepath(user, NO);
    if (!file_exists(path)) {
        NSLog(@"contacts not found: %@", path);
        return nil;
    }
    NSLog(@"loading contacts from %@", path);
    NSMutableArray<DIMID *> *contacts;
    DIMID *ID;
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    contacts = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSString *item in array) {
        ID = [self IDWithString:item];
        if (![ID isValid]) {
            NSAssert(false, @"contact ID invalid: %@", item);
            continue;
        }
        [contacts addObject:ID];
    }
    return contacts;
}

- (nullable NSArray<DIMID *> *)loadMembersForGroup:(DIMID *)group {
    NSString *path = members_filepath(group, NO);
    if (!file_exists(path)) {
        NSLog(@"members not found: %@", path);
        return nil;
    }
    //NSLog(@"loading members from %@", path);
    NSMutableArray<DIMID *> *members;
    DIMID *ID;
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    members = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSString *item in array) {
        ID = [self IDWithString:item];
        if (![ID isValid]) {
            NSAssert(false, @"members ID invalid: %@", item);
            continue;
        }
        [members addObject:ID];
    }
    return members;
}

#pragma mark Inner functions

- (BOOL)_storeMeta:(DIMMeta *)meta forID:(DIMID *)ID {
    // check default directory
    NSString *path = meta_filepath(ID, YES);
    if (file_exists(path)) {
        // no need to update meta file
        return YES;
    }
    return [meta writeToBinaryFile:path];
}

- (BOOL)_storeProfile:(DIMProfile *)profile {
    // save in default directory
    NSString *path = profile_filepath(profile.ID, YES);
    return [profile writeToBinaryFile:path];
}

- (BOOL)_storeContacts:(NSArray *)contacts forUser:(DIMLocalUser *)user {
    // save in default directory
    NSString *path = contacts_filepath(user.ID, YES);
    return [contacts writeToFile:path atomically:YES];
}

- (BOOL)saveMembers:(NSArray *)members forGroup:(DIMGroup *)group {
    // save in default directory
    NSString *path = members_filepath(group.ID, YES);
    return [members writeToFile:path atomically:YES];
}

@end
