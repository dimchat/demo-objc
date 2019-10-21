//
//  DIMProfileTable.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"
#import "DIMFacebook.h"
#import "DIMClientConstants.h"
#import "DIMProfileTable.h"

typedef NSMutableDictionary<DIMID *, DIMProfile *> CacheTableM;

@interface DIMProfileTable () {
    
    CacheTableM *_caches;
}

@end

@implementation DIMProfileTable

- (instancetype)init {
    if (self = [super init]) {
        _caches = [[CacheTableM alloc] init];
    }
    return self;
}

/**
 *  Get profile filepath in Documents Directory
 *
 * @param ID - entity ID
 * @return "Documents/.mkm/{address}/profile.plist"
 */
- (NSString *)_filePathWithID:(DIMID *)ID {
    NSString *dir = self.documentDirectory;
    dir = [dir stringByAppendingPathComponent:@".mkm"];
    dir = [dir stringByAppendingPathComponent:ID.address];
    return [dir stringByAppendingPathComponent:@"profile.plist"];
}

- (BOOL)_verifyProfile:(DIMProfile *)profile {
    if (!profile) {
        return NO;
    } else if ([profile isValid]) {
        // already verified
        return YES;
    }
    DIMID *ID = profile.ID;
    NSAssert([ID isValid], @"profile ID not valid: %@", profile);
    DIMMeta *meta = nil;
    // check signer
    if (MKMNetwork_IsUser(ID.type)) {
        // verify with user's meta.key
        meta = DIMMetaForID(ID);
    } else if (MKMNetwork_IsGroup(ID.type)) {
        if (ID.type == MKMNetwork_Polylogue) {
            // verify with group found's key (AKA meta.key)
            meta = DIMMetaForID(ID);
        } else {
            // verify with group owner's meta.key
            DIMGroup *group = DIMGroupWithID(ID);
            DIMID *owner = group.owner;
            if ([owner isValid]) {
                meta = DIMMetaForID(owner);
            }
        }
    }
    return [profile verify:meta.key];
}

- (BOOL)_cacheProfile:(DIMProfile *)profile {
    if (![self _verifyProfile:profile]) {
        //NSAssert(false, @"profile not valid: %@", profile);
        return NO;
    }
    [_caches setObject:profile forKey:profile.ID];
    return YES;
}

- (nullable __kindof DIMProfile *)_loadProfileForID:(DIMID *)ID {
    NSString *path = [self _filePathWithID:ID];
    NSDictionary *dict = [self dictionaryWithContentsOfFile:path];
    if (!dict) {
        NSLog(@"profile not found: %@", path);
        return nil;
    }
    NSLog(@"profile from: %@", path);
    return MKMProfileFromDictionary(dict);
}

- (nullable DIMProfile *)profileForID:(DIMID *)ID {
    DIMProfile *profile = [_caches objectForKey:ID];
    if (!profile) {
        // first access, try to load from local storage
        profile = [self _loadProfileForID:ID];
        if (profile) {
            // verify and cache it
            [self _cacheProfile:profile];
        } else {
            // place an empty profile for cache
            profile = [[DIMProfile alloc] initWithID:ID];
            [_caches setObject:profile forKey:ID];
        }
    }
    return profile;
}

- (BOOL)saveProfile:(DIMProfile *)profile {
    
    NSDate *now = [[NSDate alloc] init];
    [profile setObject:NSNumberFromDate(now) forKey:@"lastTime"];
    
    if (![self _cacheProfile:profile]) {
        return NO;
    }
    NSString *path = [self _filePathWithID:profile.ID];
    NSLog(@"saving profile into: %@", path);
    BOOL result = [self dictionary:profile writeToBinaryFile:path];
    
    if(result){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName_ProfileUpdated object:nil userInfo:@{@"ID":profile.ID}];
    }
    
    return result;
}

@end
