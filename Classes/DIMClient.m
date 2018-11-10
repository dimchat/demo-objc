//
//  DIMClient.m
//  DIMC
//
//  Created by Albert Moky on 2018/10/16.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMClient.h"

@interface DIMClient ()

@property (strong, nonatomic) NSMutableArray<MKMUser *> *users;

@end

/**
 Load built-in accounts for test
 
 @param filename - immortal account data file
 */
static inline MKMUser *load_immortal_file(NSString *filename) {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:filename ofType:@"plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        NSLog(@"file not exists: %@", path);
        return nil;
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
    MKMUser *user = [[MKMUser alloc] initWithID:ID
                                      publicKey:meta.key];
    MKMContact *contact = [[MKMContact alloc] initWithID:ID
                                               publicKey:meta.key];
    
    // 2. save entities into barrack
    [barrack addUser:user];
    [barrack addContact:contact];
    
    // 3. store private key into keychain
    MKMPrivateKey *SK = [dict objectForKey:@"privateKey"];
    SK = [MKMPrivateKey keyWithKey:SK];
    assert(SK.algorithm);
    [SK saveKeyWithIdentifier:ID.address];
    
    // 4. save meta & profile into barrack
    [barrack setMeta:meta forID:ID];
    [barrack addProfile:profile];
    
    return user;
}

@implementation DIMClient

SingletonImplementations(DIMClient, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _users = [[NSMutableArray alloc] init];
        _currentUser = nil;
        
#if DEBUG
        // Immortals
        MKMUser *user;
        user = load_immortal_file(@"mkm_hulk");
        [self addUser:user];
        user = load_immortal_file(@"mkm_moki");
        [self addUser:user];
#endif
    }
    return self;
}

- (NSString *)userAgent {
    return @"DIMP/1.0 (iPad; U; iOS 11.4; zh-CN) DIMCoreKit/1.0 (Terminal, like WeChat) DIM-by-GSP/1.0.1";
}

#pragma mark - Users

- (void)setCurrentUser:(MKMUser *)currentUser {
    if (![_currentUser isEqual:currentUser]) {
        _currentUser = currentUser;
        // add to the list of this client
        if (currentUser && ![_users containsObject:currentUser]) {
            [_users addObject:currentUser];
        }
        
        // update keystore
        [DIMKeyStore sharedInstance].currentUser = currentUser;
    }
}

- (void)addUser:(MKMUser *)user {
    if (user && ![_users containsObject:user]) {
        [_users addObject:user];
    }
    // check current user
    if (!_currentUser) {
        _currentUser = user;
    }
}

- (void)removeUser:(MKMUser *)user {
    if ([_users containsObject:user]) {
        [_users removeObject:user];
    }
    // check current user
    if ([_currentUser isEqual:user]) {
        _currentUser = _users.firstObject;
    }
}

@end
