//
//  DIMClient.m
//  DIMC
//
//  Created by Albert Moky on 2018/10/16.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSObject+JsON.h"

#import "DIMEnvelope.h"
#import "DIMCertifiedMessage.h"

#import "DIMStation.h"

#import "DIMClient+Message.h"
#import "DIMClient.h"

@interface DIMClient () {
    
    NSMutableArray<DIMUser *> *_users;
}

@end

/**
 Load built-in accounts for test
 
 @param filename - immortal account data file
 */
static void load_immortal_file(NSString *filename) {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:filename ofType:@"plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        NSLog(@"file not exists: %@", path);
        return ;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    // ID
    MKMID *ID = [dict objectForKey:@"ID"];
    ID = [MKMID IDWithID:ID];
    assert(ID.isValid);
    
    // meta
    MKMMeta *meta = [dict objectForKey:@"meta"];
    meta = [MKMMeta metaWithMeta:meta];
    assert([meta matchID:ID]);
    
    // profile
    id profile = [dict objectForKey:@"profile"];
    if (profile) {
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
        [mDict setObject:ID forKey:@"ID"];
        [mDict addEntriesFromDictionary:profile];
        profile = mDict;
    }
    profile = [MKMAccountProfile profileWithProfile:profile];
    assert(profile);
    
    MKMBarrack *barrack = [MKMBarrack sharedInstance];
    
    // 1. create contact & user
    DIMUser *user = [[DIMUser alloc] initWithID:ID
                                      publicKey:meta.key];
    DIMContact *contact = [[DIMContact alloc] initWithID:ID
                                               publicKey:meta.key];
    
    // 2. save entities into barrack
    [barrack addUser:user];
    [barrack addContact:contact];
    
    // 3. store private key into keychain
    MKMPrivateKey *SK = [dict objectForKey:@"privateKey"];
    SK = [MKMPrivateKey keyWithKey:SK];
    assert(SK.algorithm);
    [SK saveKeyWithIdentifier:ID.address];
    
    // 4. save profiles into barrack
    [barrack addProfile:profile];
}

@implementation DIMClient

SingletonImplementations(DIMClient, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _users = [[NSMutableArray alloc] init];
        _currentUser = nil;
        
#if DEBUG
        // Immortals
        load_immortal_file(@"mkm_hulk");
        load_immortal_file(@"mkm_moki");
#endif
    }
    return self;
}

- (NSString *)userAgent {
    return @"DIMP/1.0 (iPad; U; iOS 11.4; zh-CN) DIMCoreKit/1.0 (Terminal, like WeChat) DIM-by-GSP/1.0.1";
}

#pragma mark - Users

- (void)setCurrentUser:(DIMUser *)currentUser {
    if (![_currentUser isEqual:currentUser]) {
        _currentUser = currentUser;
        // add to list
        if (currentUser && ![_users containsObject:currentUser]) {
            [_users addObject:currentUser];
        }
    }
}

- (void)addUser:(DIMUser *)user {
    if (user && ![_users containsObject:user]) {
        [_users addObject:user];
    }
    // check current user
    if (!_currentUser) {
        _currentUser = user;
    }
}

- (void)removeUser:(DIMUser *)user {
    if ([_users containsObject:user]) {
        [_users removeObject:user];
    }
    // check current user
    if ([_currentUser isEqual:user]) {
        _currentUser = _users.firstObject;
    }
}

@end
