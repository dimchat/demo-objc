//
//  DIMBarrack.m
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMBarrack.h"

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
    
    // 1. create contact & user
    DIMUser *user = [[DIMUser alloc] initWithID:ID publicKey:meta.key];
    [user updateProfile:profile];
    DIMContact *contact = [[DIMContact alloc] initWithID:ID publicKey:meta.key];
    [contact updateProfile:profile];
    
    // 2. add to entity manager
    MKMEntityManager *eman = [MKMEntityManager sharedInstance];
    [eman addUser:user];
    [eman addContact:contact];
    
    // 3. store private key into keychain
    MKMPrivateKey *SK = [dict objectForKey:@"privateKey"];
    SK = [MKMPrivateKey keyWithKey:SK];
    assert(SK.algorithm);
    [SK saveKeyWithIdentifier:ID.address];
}

@implementation DIMBarrack

SingletonImplementations(DIMBarrack, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        [MKMEntityManager sharedInstance].delegate = self;
        [MKMProfileManager sharedInstance].dataSource = self;
#if DEBUG
        // Immortals
        load_immortal_file(@"mkm_hulk");
        load_immortal_file(@"mkm_moki");
#endif
    }
    return self;
}

- (void)reduceMemory {
    [[MKMEntityManager sharedInstance] reduceMemory];
    [[MKMProfileManager sharedInstance] reduceMemory];
}

#pragma mark - MKMEntityDelegate

- (MKMContact *)contactWithID:(const MKMID *)ID {
    // TODO:
    return nil;
}

- (MKMUser *)userWithID:(const MKMID *)ID {
    // TODO:
    return nil;
}

- (MKMGroup *)groupWithID:(const MKMID *)ID {
    // TODO:
    return nil;
}

- (MKMMember *)memberWithID:(const MKMID *)ID groupID:(const MKMID *)gID {
    // TODO:
    return nil;
}

#pragma mark - MKMProfileDataSource

- (MKMProfile *)profileForID:(const MKMID *)ID {
    // TODO:
    return nil;
}

- (MKMMemo *)memoForID:(const MKMID *)ID {
    // TODO:
    return nil;
}

@end
