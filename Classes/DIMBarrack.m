//
//  DIMBarrack.m
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMBarrack.h"

@interface MKMEntity (Hacking)

@property (strong, nonatomic) MKMMeta *meta;
@property (strong, nonatomic) MKMHistory *history;

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
        
        [MKMEntityManager sharedInstance].delegate = self;
        [MKMFacebook sharedInstance].delegate = self;
    }
    return self;
}

#pragma mark User

- (DIMUser *)userForID:(const MKMID *)ID {
    DIMUser *user = [_userTable objectForKey:ID.address];
    if (!user) {
        // create new user with ID
        user = [DIMUser userWithID:ID];
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
        // create new contact with ID
        contact = [DIMContact contactWithID:ID];
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
    // TODO: post onto network
    NSLog(@"post history of %@: %@", ID, history);
}

- (void)postHistoryRecord:(const MKMHistoryRecord *)record
                    forID:(const MKMID *)ID {
    // TODO: post onto network
    NSLog(@"post history record of %@: %@", ID, record);
}

- (void)postMeta:(const MKMMeta *)meta
           forID:(const MKMID *)ID {
    // TODO: post onto network
    NSLog(@"post meta of %@: %@", ID, meta);
}

- (void)postMeta:(const MKMMeta *)meta
         history:(const MKMHistory *)history
           forID:(const MKMID *)ID {
    // TODO: post onto network
    NSLog(@"post meta of %@: %@", ID, meta);
    NSLog(@"and history of %@: %@", ID, history);
}

- (nullable MKMHistory *)queryHistoryWithID:(const MKMID *)ID {
    MKMHistory *history = nil;
    
    do {
        // try contact pool
        DIMContact *contact = [_contactTable objectForKey:ID.address];
        if (contact) {
            history = contact.history;
            break;
        }
        
        // try user pool
        DIMUser *user = [_userTable objectForKey:ID.address];
        if (user) {
            history = user.history;
            break;
        }
    } while (false);

    // TODO: query from network to update, don't do it too frequently
    NSLog(@"querying history of %@", ID);
    return history;
}

- (nullable MKMMeta *)queryMetaWithID:(const MKMID *)ID {
    MKMMeta *meta = nil;
    
    do {
        // try contact pool
        DIMContact *contact = [_contactTable objectForKey:ID.address];
        if (contact) {
            meta = contact.meta;
            break;
        }
        
        // try user pool
        DIMUser *user = [_userTable objectForKey:ID.address];
        if (user) {
            meta = user.meta;
            break;
        }
    } while (false);
    
    if (!meta) {
        // TODO: query from network if not found
        NSLog(@"querying meta of %@", ID);
    }
    return meta;
}

#pragma mark - MKMProfileDelegate

- (void)postProfile:(const MKMProfile *)profile
              forID:(const MKMID *)ID {
    // TODO: post onto network
    NSLog(@"post profile of %@: %@", ID, profile);
}

- (nullable MKMProfile *)queryProfileWithID:(const MKMID *)ID {
    MKMProfile *profile = nil;
    
    do {
        // try contact pool
        DIMContact *contact = [_contactTable objectForKey:ID.address];
        if (contact) {
            profile = contact.profile;
            break;
        }
        
        // try user pool
        DIMUser *user = [_userTable objectForKey:ID.address];
        if (user) {
            profile = user.profile;
            break;
        }
    } while (false);
    
    // TODO: query from network to update, don't do it too frequently
    NSLog(@"querying profile of %@", ID);
    return nil;
}

@end
