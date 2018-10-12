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
    
    NSMutableDictionary<const MKMID *, DIMUser *> *_userTable;
    NSMutableDictionary<const MKMID *, DIMContact *> *_contactTable;
    
    NSMutableDictionary<const MKMID *, DIMGroup *> *_groupTable;
    NSMutableDictionary<const MKMID *, DIMMoments *> *_momentsTable;
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
    DIMUser *user = [_userTable objectForKey:ID];
    if (!user) {
        // create new user with ID
        user = [DIMUser userWithID:ID];
        [self setUser:user];
    }
    return user;
}

- (void)setUser:(DIMUser *)user {
    [_userTable setObject:user forKey:user.ID];
    // check moments for ID, maybe created by other contact
    DIMMoments *moments = [_momentsTable objectForKey:user.ID];
    if (!moments) {
        // create moments for this user
        moments = [DIMMoments momentsWithID:user.ID];
        [_momentsTable setObject:moments forKey:user.ID];
        [_momentsTable setObject:moments forKey:moments.ID];
    }
}

- (void)removeUser:(const DIMUser *)user {
    [_userTable removeObjectForKey:user.ID];
    // remove moments of this user
    MKMID *ID = user.moments;
    [_momentsTable removeObjectForKey:ID];
    [_momentsTable removeObjectForKey:user.ID];
}

#pragma mark Contact

- (DIMContact *)contactForID:(const MKMID *)ID {
    DIMContact *contact = [_contactTable objectForKey:ID];
    if (!contact) {
        // create new contact with ID
        contact = [DIMContact contactWithID:ID];
        [self setContact:contact];
    }
    return contact;
}

- (void)setContact:(DIMContact *)contact {
    [_contactTable setObject:contact forKey:contact.ID];
    // check moments for ID, maybe created by other user
    DIMMoments *moments = [_momentsTable objectForKey:contact.ID];
    if (!moments) {
        // create moments for this contact
        moments = [DIMMoments momentsWithID:contact.ID];
        [_momentsTable setObject:moments forKey:contact.ID];
        [_momentsTable setObject:moments forKey:moments.ID];
    }
}

- (void)removeContact:(const DIMContact *)contact {
    [_contactTable removeObjectForKey:contact.ID];
    // remove moments of this contact
    MKMID *ID = contact.moments;
    [_momentsTable removeObjectForKey:ID];
    [_momentsTable removeObjectForKey:contact.ID];
}

#pragma mark Group

- (DIMGroup *)groupForID:(const MKMID *)ID {
    DIMGroup *group = [_groupTable objectForKey:ID];
    if (!group) {
        // create new group with ID
        group = [DIMGroup groupWithID:ID];
        [self setGroup:group];
    }
    return group;
}

- (void)setGroup:(DIMGroup *)group {
    [_groupTable setObject:group forKey:group.ID];
}

- (void)removeGroup:(const DIMGroup *)group {
    [_groupTable removeObjectForKey:group.ID];
}

#pragma mark Moments

- (DIMMoments *)momentsForID:(const MKMID *)ID {
    DIMMoments *moments = [_momentsTable objectForKey:ID];
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
    // try contact pool
    DIMContact *contact = [_contactTable objectForKey:ID];
    if (contact) {
        return contact.history;
    }
    // try user pool
    DIMUser *user = [_userTable objectForKey:ID];
    if (user) {
        return user.history;
    }
    
    // TODO: query from network
    NSLog(@"querying history of %@", ID);
    return nil;
}

- (nullable MKMMeta *)queryMetaWithID:(const MKMID *)ID {
    // try contact pool
    DIMContact *contact = [_contactTable objectForKey:ID];
    if (contact) {
        return contact.meta;
    }
    // try user pool
    DIMUser *user = [_userTable objectForKey:ID];
    if (user) {
        return user.meta;
    }
    
    // TODO: query from network
    NSLog(@"querying meta of %@", ID);
    return nil;
}

#pragma mark - MKMProfileDelegate

- (void)postProfile:(const MKMProfile *)profile
              forID:(const MKMID *)ID {
    // TODO: post onto network
    NSLog(@"post profile of %@: %@", ID, profile);
}

- (nullable MKMProfile *)queryProfileWithID:(const MKMID *)ID {
    // try contact pool
    DIMContact *contact = [_contactTable objectForKey:ID];
    if (contact) {
        return contact.profile;
    }
    // try user pool
    DIMUser *user = [_userTable objectForKey:ID];
    if (user) {
        return user.profile;
    }
    
    // TODO: query from network
    NSLog(@"querying profile of %@", ID);
    return nil;
}

@end
