//
//  DIMContactTable.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMFacebook.h"

#import "DIMContactTable.h"

typedef NSMutableDictionary<DIMID *, NSArray *> CacheTableM;

@interface DIMContactTable () {
    
    CacheTableM *_caches;
}

@end

@implementation DIMContactTable

- (instancetype)init {
    if (self = [super init]) {
        _caches = [[CacheTableM alloc] init];
    }
    return self;
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
