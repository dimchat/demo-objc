//
//  DIMProfileTable.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DIMFacebook.h"

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
    if (profile) {
        // check timestamp
        NSNumber *timestamp = [profile objectForKey:@"lastTime"];
        if (timestamp) {
            NSDate *lastTime = NSDateFromNumber(timestamp);
            NSTimeInterval ti = [lastTime timeIntervalSinceNow];
            if (fabs(ti) < 3600) {
                // not expired yet
                return profile;
            }
            NSLog(@"profile expired: %@", lastTime);
            [_caches removeObjectForKey:ID];
        } else {
            // set last update time
            NSDate *now = [[NSDate alloc] init];
            [profile setObject:NSNumberFromDate(now) forKey:@"lastTime"];
            return profile;
        }
    }
    profile = [self _loadProfileForID:ID];
    // check and cache it
    if (!profile || ![self _cacheProfile:profile]) {
        // place an empty profile for cache
        profile = [[DIMProfile alloc] initWithID:ID];
        [_caches setObject:profile forKey:ID];
    }
    return profile;
}

- (BOOL)saveProfile:(DIMProfile *)profile {
    if (![self _cacheProfile:profile]) {
        return NO;
    }
    NSString *path = [self _filePathWithID:profile.ID];
    NSLog(@"saving profile into: %@", path);
    return [self dictionary:profile writeToBinaryFile:path];
}

@end
