//
//  DIMBarrack.m
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

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
    
    // history
    MKMHistory *history = [dict objectForKey:@"history"];
    history = [MKMHistory historyWithHistory:history];
    assert(history.count > 0);
    
    // private key
    MKMPrivateKey *SK = [dict objectForKey:@"privateKey"];
    SK = [MKMPrivateKey keyWithKey:SK];
    assert(SK.algorithm);
    
    // profile
    id profile = [dict objectForKey:@"profile"];
    if (profile) {
        NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
        [mDict setObject:ID forKey:@"ID"];
        [mDict addEntriesFromDictionary:profile];
        profile = mDict;
    }
    profile = [MKMProfile profileWithProfile:profile];
    assert(profile);
    
    MKMEntityManager *eman = [MKMEntityManager sharedInstance];
    MKMProfileManager *facebook = [MKMProfileManager sharedInstance];
    
    // 1. store meta & history by entity manager
    [eman setMeta:meta forID:ID];
    [eman setHistory:history forID:ID];
    
    // 2. store private key by keychain
    [SK saveKeyWithIdentifier:ID.address];
    
    // 3. store profile by profile manager (facebook)
    [facebook setProfile:profile forID:ID];
}

@interface MKMEntity (Hacking)

@property (strong, nonatomic) MKMMeta *meta;
@property (strong, nonatomic) MKMHistory *history;

@end

@interface MKMAccount (Hacking)

@property (strong, nonatomic) MKMAccountProfile *profile;

@end

@interface DIMBarrack () {
    
    NSMutableDictionary<const MKMAddress *, DIMUser *> *_userTable;
    NSMutableDictionary<const MKMAddress *, DIMContact *> *_contactTable;
    
    NSMutableDictionary<const MKMAddress *, DIMGroup *> *_groupTable;
}

@end

@implementation DIMBarrack

static DIMBarrack *s_sharedInstance = nil;

+ (instancetype)sharedInstance {
    if (!s_sharedInstance) {
        s_sharedInstance = [[self alloc] init];
    }
    return s_sharedInstance;
}

+ (instancetype)alloc {
    NSAssert(!s_sharedInstance, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        _userTable = [[NSMutableDictionary alloc] init];
        _contactTable = [[NSMutableDictionary alloc] init];
        
        _groupTable = [[NSMutableDictionary alloc] init];
        
#if DEBUG
        // Immortals
        load_immortal_file(@"mkm_hulk");
        load_immortal_file(@"mkm_moki");
#endif
    }
    return self;
}

#pragma mark User

- (DIMUser *)userForID:(const MKMID *)ID {
    DIMUser *user = [_userTable objectForKey:ID.address];
    if (!user) {
        // get profile with ID
        MKMProfileManager *facebook = [MKMProfileManager sharedInstance];
        id prof = [facebook profileWithID:ID];
        prof = [MKMAccountProfile profileWithProfile:prof];
        // create new user with ID
        user = [DIMUser userWithID:ID];
        user.profile = prof;
        [self setUser:user];
    }
    return user;
}

- (void)setUser:(DIMUser *)user {
    [_userTable setObject:user forKey:user.ID.address];
}

- (void)removeUser:(DIMUser *)user {
    [_userTable removeObjectForKey:user.ID.address];
}

#pragma mark Contact

- (DIMContact *)contactForID:(const MKMID *)ID {
    DIMContact *contact = [_contactTable objectForKey:ID.address];
    if (!contact) {
        // get profile with ID
        MKMProfileManager *facebook = [MKMProfileManager sharedInstance];
        id prof = [facebook profileWithID:ID];
        prof = [MKMAccountProfile profileWithProfile:prof];
        // create new contact with ID
        contact = [DIMContact contactWithID:ID];
        contact.profile = prof;
        [self setContact:contact];
    }
    return contact;
}

- (void)setContact:(DIMContact *)contact {
    [_contactTable setObject:contact forKey:contact.ID.address];
}

- (void)removeContact:(DIMContact *)contact {
    [_contactTable removeObjectForKey:contact.ID.address];
}

#pragma mark Group

- (DIMGroup *)groupForID:(const MKMID *)ID {
    DIMGroup *group = [_groupTable objectForKey:ID.address];
    if (!group) {
        // create new group with ID
        group = [DIMGroup groupWithID:ID];
        [self setGroup:group];
    }
    return group;
}

- (void)setGroup:(DIMGroup *)group {
    [_groupTable setObject:group forKey:group.ID.address];
}

- (void)removeGroup:(DIMGroup *)group {
    [_groupTable removeObjectForKey:group.ID.address];
}

@end
