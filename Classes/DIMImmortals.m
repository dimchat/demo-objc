//
//  DIMImmortals.m
//  DIMC
//
//  Created by Albert Moky on 2018/11/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMClient.h"

#import "DIMImmortals.h"

@interface DIMImmortals () {
    
    NSMutableDictionary<const MKMAddress *, MKMMeta *> *_metaTable;
    NSMutableDictionary<const MKMAddress *, MKMProfile *> *_profileTable;
}

@end

@implementation DIMImmortals

- (instancetype)init {
    if (self = [super init]) {
        _metaTable    = [[NSMutableDictionary alloc] initWithCapacity:2];
        _profileTable = [[NSMutableDictionary alloc] initWithCapacity:2];
        
        [self _loadBuiltInAccount:@"mkm_hulk"];
        [self _loadBuiltInAccount:@"mkm_moki"];
    }
    return self;
}

- (MKMUser *)_loadBuiltInAccount:(NSString *)filename {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:filename ofType:@"plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        NSAssert(false, @"file not exists: %@", path);
        return nil;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // ID
    MKMID *ID = [dict objectForKey:@"ID"];
    ID = [MKMID IDWithID:ID];
    NSAssert(ID.isValid, @"ID error");
    
    // meta
    MKMMeta *meta = [dict objectForKey:@"meta"];
    meta = [MKMMeta metaWithMeta:meta];
    if ([meta matchID:ID]) {
        [_metaTable setObject:meta forKey:ID.address];
        [MKMFacebook() setMeta:meta forID:ID];
    } else {
        NSAssert(false, @"meta error");
    }
    
    // profile
    MKMAccountProfile *profile = [dict objectForKey:@"profile"];
    profile = [MKMAccountProfile profileWithProfile:profile];
    if (profile) {
        [_profileTable setObject:profile forKey:ID.address];
    } else {
        NSAssert(false, @"profile error");
    }
    
    // private key
    MKMPrivateKey *SK = [dict objectForKey:@"privateKey"];
    SK = [MKMPrivateKey keyWithKey:SK];
    if ([meta matchID:ID] && [meta.key isMatch:SK]) {
        // store private key into keychain
        [SK saveKeyWithIdentifier:ID.address];
    } else {
        NSAssert(false, @"keys not match");
    }
    
    // create
    MKMUser *user = [[MKMUser alloc] initWithID:ID publicKey:meta.key];
    [MKMFacebook() addUser:user];
#if DEBUG
    [[DIMClient sharedInstance] addUser:user];
#endif
    return user;
}

#pragma mark - Delegates

- (MKMUser *)userWithID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"not user ID");
    MKMUser *user = nil;
    // meta
    MKMMeta *meta = [self metaForEntityID:ID];
    if (meta) {
        user = [[MKMUser alloc] initWithID:ID publicKey:meta.key];
        // profile.name
        MKMProfile *profile = [self profileForID:ID];
        NSAssert(profile.name, @"profile.name not found");
        user.name = profile.name;
    }
    return user;
}

- (MKMContact *)contactWithID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"not account ID");
    MKMContact *contact = nil;
    // meta
    MKMMeta *meta = [self metaForEntityID:ID];
    if (meta) {
        contact = [[MKMContact alloc] initWithID:ID publicKey:meta.key];
        // profile.name
        MKMProfile *profile = [self profileForID:ID];
        NSAssert(profile.name, @"profile.name not found");
        contact.name = profile.name;
    }
    return contact;
}

- (MKMMeta *)metaForEntityID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"not account ID");
    return [_metaTable objectForKey:ID.address];
}

- (MKMProfile *)profileForID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"not account ID");
    return [_profileTable objectForKey:ID.address];
}

@end
