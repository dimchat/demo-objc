//
//  MKMImmortals.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPrivateKey.h"
#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMBarrack.h"

//#if DEBUG
//#import "DKDClient.h"
//#endif

#import "MKMImmortals.h"

@interface MKMImmortals () {
    
    NSMutableDictionary<const MKMAddress *, MKMMeta *> *_metaTable;
    NSMutableDictionary<const MKMAddress *, MKMProfile *> *_profileTable;
    
    NSMutableDictionary<const MKMAddress *, MKMUser *> *_userTable;
    NSMutableDictionary<const MKMAddress *, MKMContact *> *_contactTable;
}

@end

@implementation MKMImmortals

- (instancetype)init {
    if (self = [super init]) {
        _metaTable    = [[NSMutableDictionary alloc] initWithCapacity:2];
        _profileTable = [[NSMutableDictionary alloc] initWithCapacity:2];
        
        _userTable    = [[NSMutableDictionary alloc] initWithCapacity:2];
        _contactTable = [[NSMutableDictionary alloc] initWithCapacity:2];
        
        [self _loadBuiltInAccount:@"mkm_hulk"];
        [self _loadBuiltInAccount:@"mkm_moki"];
    }
    return self;
}

- (MKMRegisterInfo *)_loadBuiltInAccount:(NSString *)filename {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];//[NSBundle mainBundle];
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
        //[SK saveKeyWithIdentifier:ID.address];
    } else {
        NSAssert(false, @"keys not match");
        SK = nil;
    }
    
    // create contact & user
    MKMContact *contact = [[MKMContact alloc] initWithID:ID publicKey:meta.key];
    [_contactTable setObject:contact forKey:ID.address];
    
    MKMUser *user = [[MKMUser alloc] initWithID:ID publicKey:meta.key];
    user.privateKey = SK;
    [_userTable setObject:user forKey:ID.address];
    
//#if DEBUG
//    [[DKDClient sharedInstance] addUser:user];
//#endif
    
    MKMRegisterInfo *info = [[MKMRegisterInfo alloc] init];
    info.privateKey = SK;
    info.publicKey = SK.publicKey;
    info.meta = meta;
    info.ID = ID;
    info.user = user;
    return info;
}

#pragma mark - Delegates

- (MKMUser *)userWithID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsPerson(ID.type), @"not user ID");
    MKMUser *user = [_userTable objectForKey:ID.address];
    if (user) {
        return user;
    }
    // create with meta.key
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
    MKMContact *contact = [_contactTable objectForKey:ID.address];
    if (contact) {
        return contact;
    }
    // create with meta.key
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
