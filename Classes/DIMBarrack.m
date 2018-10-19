//
//  DIMBarrack.m
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMBarrack.h"

static inline NSString *documents_directory(void) {
    NSArray *paths;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                NSUserDomainMask, YES);
    return paths.firstObject;
}

/**
 Get full filepath to Documents Directory

 @param ID - contact ID
 @param filename - "*.plist"
 @return "Documents/barrack/{address}/\*.plist"
 */
static inline NSString *full_filepath(const MKMID *ID, NSString *filename) {
    // base directory: Documents/barrack/{address}
    NSString *dir = documents_directory();
    dir = [dir stringByAppendingPathComponent:@"barrack"];
    MKMAddress *addr = ID.address;
    dir = [dir stringByAppendingPathComponent:addr];
    
    // check base directory exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir isDirectory:nil]) {
        NSError *error = nil;
        // make sure directory exists
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES
                       attributes:nil error:&error];
        assert(!error);
    }
    
    // build filepath
    return [dir stringByAppendingPathComponent:filename];
}

static inline BOOL file_exists(NSString *path) {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:path];
}

static void load_immortal_file(NSString *filename) {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:filename ofType:@"plist"];
    if (!file_exists(path)) {
        NSLog(@"cannot load: %@", path);
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
    MKMProfile *profile = [dict objectForKey:@"profile"];
    profile = [MKMProfile profileWithProfile:profile];
    assert(profile);
    
    MKMEntityManager *eman = [MKMEntityManager sharedInstance];
    MKMFacebook *facebook = [MKMFacebook sharedInstance];
    
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
    NSMutableDictionary<const MKMAddress *, DIMMoments *> *_momentsTable;
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
        _momentsTable = [[NSMutableDictionary alloc] init];
        
#if DEBUG
        // Immortals
        load_immortal_file(@"mkm_hulk");
        load_immortal_file(@"mkm_moki");
#endif
        
        [MKMEntityManager sharedInstance].delegate = self;
        [MKMFacebook sharedInstance].delegate = self;
    }
    return self;
}

#pragma mark User

- (DIMUser *)userForID:(const MKMID *)ID {
    DIMUser *user = [_userTable objectForKey:ID.address];
    if (!user) {
        // get profile with ID
        MKMFacebook *facebook = [MKMFacebook sharedInstance];
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
    
    // check moments for ID, maybe created by other contact
    DIMMoments *moments = [_momentsTable objectForKey:user.ID.address];
    if (!moments) {
        // create moments for this user
        moments = [DIMMoments momentsWithID:user.ID];
        [_momentsTable setObject:moments forKey:user.ID.address];
        [_momentsTable setObject:moments forKey:moments.ID.address];
    }
}

- (void)removeUser:(const DIMUser *)user {
    [_userTable removeObjectForKey:user.ID.address];
    
    // remove moments of this user
    MKMID *ID = user.moments;
    [_momentsTable removeObjectForKey:ID.address];
    [_momentsTable removeObjectForKey:user.ID.address];
}

#pragma mark Contact

- (DIMContact *)contactForID:(const MKMID *)ID {
    DIMContact *contact = [_contactTable objectForKey:ID.address];
    if (!contact) {
        // get profile with ID
        MKMFacebook *facebook = [MKMFacebook sharedInstance];
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
    
    // check moments for ID, maybe created by other user
    DIMMoments *moments = [_momentsTable objectForKey:contact.ID.address];
    if (!moments) {
        // create moments for this contact
        moments = [DIMMoments momentsWithID:contact.ID];
        [_momentsTable setObject:moments forKey:contact.ID.address];
        [_momentsTable setObject:moments forKey:moments.ID.address];
    }
}

- (void)removeContact:(const DIMContact *)contact {
    [_contactTable removeObjectForKey:contact.ID.address];
    
    // remove moments of this contact
    MKMID *ID = contact.moments;
    [_momentsTable removeObjectForKey:ID.address];
    [_momentsTable removeObjectForKey:contact.ID.address];
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

- (void)removeGroup:(const DIMGroup *)group {
    [_groupTable removeObjectForKey:group.ID.address];
}

#pragma mark Moments

- (DIMMoments *)momentsForID:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Main, @"must be account");
    DIMMoments *moments = [_momentsTable objectForKey:ID.address];
    NSAssert(moments, @"set user/contact first");
    return moments;
}

//- (void)setMoments:(DIMMoments *)moments {
//    [_momentsTable setObject:moments forKey:moments.ID];
//}
//
//- (void)removeMoments:(const DIMMoments *)moments {
//    [_momentsTable removeObjectForKey:moments.ID];
//}

#pragma mark - MKMEntityDelegate

- (void)postHistory:(const MKMHistory *)history
              forID:(const MKMID *)ID {
    // 1. check and save history in local documents
    if ([history matchID:ID]) {
        NSString *path = full_filepath(ID, @"history.plist");
        [history writeToFile:path atomically:YES];
    } else {
        NSAssert(false, @"history error: %@", history);
        return;
    }
    
    // TODO: 2. post history onto network
    NSLog(@"post history of %@: %@", ID, history);
}

- (void)postHistoryRecord:(const MKMHistoryRecord *)record
                    forID:(const MKMID *)ID {
    // 1. get record(s) from local history
    MKMHistory *history = nil;
    NSString *path = full_filepath(ID, @"history.plist");
    if (file_exists(path)) {
        NSArray *array;
        array = [NSArray arrayWithContentsOfFile:path];
        history = [[MKMHistory alloc] initWithArray:array];
    } else {
        history = [[MKMHistory alloc] init];
    }
    
    // 1.1. add new record
    [history addObject:record];
    
    // 2. check and save new history in local documents
    if ([history matchID:ID]) {
        [history writeToFile:path atomically:YES];
    } else {
        NSAssert(false, @"history record error: %@", record);
        return;
    }
    
    // TODO: 3. post history record onto network
    NSLog(@"post history record of %@: %@", ID, record);
}

- (void)postMeta:(const MKMMeta *)meta
           forID:(const MKMID *)ID {
    // 1. check and save meta in local documents
    if ([meta matchID:ID]) {
        NSString *path = full_filepath(ID, @"meta.plist");
        [meta writeToFile:path atomically:YES];
    } else {
        NSAssert(false, @"meta error: %@", meta);
        return;
    }
    
    // TODO: 2. post meta onto network
    NSLog(@"post meta of %@: %@", ID, meta);
}

- (void)postMeta:(const MKMMeta *)meta
         history:(const MKMHistory *)history
           forID:(const MKMID *)ID {
    // 1.1. check and save meta in local documents
    if ([meta matchID:ID]) {
        NSString *path = full_filepath(ID, @"meta.plist");
        [meta writeToFile:path atomically:YES];
    } else {
        NSAssert(false, @"meta error: %@", meta);
        return;
    }
    // 1.2. check and save history in local documents
    if ([history matchID:ID]) {
        NSString *path = full_filepath(ID, @"history.plist");
        [history writeToFile:path atomically:YES];
    } else {
        NSAssert(false, @"history error: %@", history);
        return;
    }
    
    // TODO: 2. post meta & history onto network
    NSLog(@"post meta of %@: %@", ID, meta);
    NSLog(@"and history of %@: %@", ID, history);
}

- (nullable MKMHistory *)queryHistoryWithID:(const MKMID *)ID {
    MKMHistory *history = nil;
    
    do {
        // 1. try contact pool
        DIMContact *contact = [_contactTable objectForKey:ID.address];
        if (contact) {
            history = contact.history;
            break;
        }
        
        // 2. try user pool
        DIMUser *user = [_userTable objectForKey:ID.address];
        if (user) {
            history = user.history;
            break;
        }
        
        // 3. try local documents
        NSString *path = full_filepath(ID, @"history.plist");
        if (file_exists(path)) {
            NSArray *array;
            array = [NSArray arrayWithContentsOfFile:path];
            MKMHistory *his = [[MKMHistory alloc] initWithArray:array];
            if (his.count > 0) {
                history = his;
                break;
            }
        }
    } while (false);

    // TODO: query from network to update, don't do it too frequently
    NSLog(@"querying history of %@", ID);
    return history;
}

- (nullable MKMMeta *)queryMetaWithID:(const MKMID *)ID {
    MKMMeta *meta = nil;
    
    do {
        // 1. try contact pool
        DIMContact *contact = [_contactTable objectForKey:ID.address];
        if (contact) {
            meta = contact.meta;
            break;
        }
        
        // 2. try user pool
        DIMUser *user = [_userTable objectForKey:ID.address];
        if (user) {
            meta = user.meta;
            break;
        }
        
        // 3. try local documents
        NSString *path = full_filepath(ID, @"meta.plist");
        if (file_exists(path)) {
            NSDictionary *dict;
            dict = [NSDictionary dictionaryWithContentsOfFile:path];
            MKMMeta *met = [[MKMMeta alloc] initWithDictionary:dict];
            if ([met matchID:ID]) {
                meta = met;
                break;
            }
        }
    } while (false);
    
    if (meta) {
        // meta won't change, no need to update
        return meta;
    }
    
    // TODO: query from network if not found
    NSLog(@"querying meta of %@", ID);
    return meta;
}

#pragma mark - MKMProfileDelegate

- (void)postProfile:(const MKMProfile *)profile
              forID:(const MKMID *)ID {
    // 1. save in local documents
    if ([profile matchID:ID]) {
        NSString *path = full_filepath(ID, @"profile.plist");
        [profile writeToFile:path atomically:YES];
    } else {
        NSAssert(false, @"profile error: %@", profile);
        return;
    }
    
    // TODO: post onto network
    NSLog(@"post profile of %@: %@", ID, profile);
}

- (nullable MKMProfile *)queryProfileWithID:(const MKMID *)ID {
    MKMProfile *profile = nil;
    
    do {
        // 1. try contact pool
        DIMContact *contact = [_contactTable objectForKey:ID.address];
        if (contact) {
            profile = contact.profile;
            break;
        }
        
        // 2. try user pool
        DIMUser *user = [_userTable objectForKey:ID.address];
        if (user) {
            profile = user.profile;
            break;
        }
        
        // 3. try local documents
        NSString *path = full_filepath(ID, @"profile.plist");
        if (file_exists(path)) {
            NSDictionary *dict;
            dict = [NSDictionary dictionaryWithContentsOfFile:path];
            MKMProfile *prof = [[MKMProfile alloc] initWithDictionary:dict];
            if ([prof matchID:ID]) {
                profile = prof;
                break;
            }
        }
    } while (false);
    
    // TODO: query from network to update, don't do it too frequently
    NSLog(@"querying profile of %@", ID);
    return nil;
}

@end
