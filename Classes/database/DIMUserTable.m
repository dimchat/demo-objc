//
//  DIMUserTable.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMFacebook.h"

#import "DIMUserTable.h"

typedef NSMutableDictionary<DIMID *, NSArray *> CacheTableM;

@interface DIMUserTable () {
    
    CacheTableM *_caches;
    
    NSMutableArray<DIMID *> *_users;
}

@end

@implementation DIMUserTable

- (instancetype)init {
    if (self = [super init]) {
        _caches = [[CacheTableM alloc] init];
        
        _users = nil;
    }
    return self;
}

/**
 *  Get users filepath in Documents Directory
 *
 * @return "Documents/.dim/users.plist"
 */
- (NSString *)_usersFilePath {
    NSString *dir = self.documentDirectory;
    dir = [dir stringByAppendingPathComponent:@".dim"];
    return [dir stringByAppendingPathComponent:@"users.plist"];
}

- (nullable NSArray<DIMID *> *)allUsers {
    if (_users) {
        return _users;
    }
    _users = [[NSMutableArray alloc] init];
    DIMID *ID;
    
    NSString *path = [self _usersFilePath];
    NSLog(@"loading users: %@", path);
    NSArray *array = [self arrayWithContentsOfFile:path];
    for (NSString *item in array) {
        ID = DIMIDWithString(item);
        NSAssert([ID isValid], @"ID error: %@", item);
        [_users addObject:ID];
    }
    
    return _users;
}

- (BOOL)saveUsers:(NSArray<DIMID *> *)list {
    // update cache
    _users = [list mutableCopy];
    // save into storage
    NSString *path = [self _usersFilePath];
    NSLog(@"saving %ld user(s): %@", list.count, path);
    return [self array:list writeToFile:path];
}

/**
 *  Get contacts filepath in Documents Directory
 *
 * @param ID - user ID
 * @return "Documents/.mkm/{address}/contacts.plist"
 */
- (NSString *)_filePathWithID:(DIMID *)ID {
    NSString *dir = self.documentDirectory;
    dir = [dir stringByAppendingPathComponent:@".mkm"];
    dir = [dir stringByAppendingPathComponent:ID.address];
    return [dir stringByAppendingPathComponent:@"contacts.plist"];
}

- (nullable NSArray<DIMID *> *)_loadContactsForUser:(DIMID *)user {
    NSString *path = [self _filePathWithID:user];
    NSArray *array = [self arrayWithContentsOfFile:path];
    if (!array) {
        NSLog(@"contacts not found: %@", path);
        return nil;
    }
    NSLog(@"contacts from %@", path);
    NSMutableArray<DIMID *> *contacts;
    DIMID *ID;
    contacts = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSString *item in array) {
        ID = DIMIDWithString(item);
        if (![ID isValid]) {
            NSAssert(false, @"contact ID invalid: %@", item);
            continue;
        }
        [contacts addObject:ID];
    }
    return contacts;
}

- (nullable NSArray<DIMID *> *)contactsOfUser:(DIMID *)user {
    NSArray<DIMID *> *contacts = [_caches objectForKey:user];
    if (!contacts) {
        contacts = [self _loadContactsForUser:user];
        if (contacts) {
            // cache it
            [_caches setObject:contacts forKey:user];
        }
    }
    return contacts;
}

- (BOOL)saveContacts:(NSArray *)contacts user:(DIMID *)user {
    NSAssert(contacts, @"contacts cannot be empty");
    // update cache
    [_caches setObject:contacts forKey:user];
    
    NSString *path = [self _filePathWithID:user];
    NSLog(@"saving contacts into: %@", path);
    return [self array:contacts writeToFile:path];
}

@end
