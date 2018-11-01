//
//  MKMEntityManager.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/2.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMContact.h"
#import "MKMUser.h"
#import "MKMGroup.h"
#import "MKMMember.h"

#import "MKMEntityManager.h"

/**
 Remove 1/2 objects from the dictionary

 @param mDict - mutable dictionary
 */
static void reduce_table(NSMutableDictionary *mDict) {
    NSArray *keys = [mDict allKeys];
    MKMAddress *addr;
    for (NSUInteger index = 0; index < keys.count; index += 2) {
        addr = [keys objectAtIndex:index];
        [mDict removeObjectForKey:addr];
    }
}

typedef NSMutableDictionary<const MKMAddress *, MKMContact *> MKMContactTable;
typedef NSMutableDictionary<const MKMAddress *, MKMUser *> MKMUserTable;

typedef NSMutableDictionary<const MKMAddress *, MKMGroup *> MKMGroupTable;
typedef NSMutableDictionary<const MKMAddress *, MKMMember *> MKMMembers;
typedef NSMutableDictionary<const MKMAddress *, MKMMembers *> MKMMemberTable;

@interface MKMEntityManager () {
    
    MKMContactTable *_contactTable;
    MKMUserTable *_userTable;
    
    MKMGroupTable *_groupTable;
    MKMMemberTable *_memberTable;
}

@end

@implementation MKMEntityManager

SingletonImplementations(MKMEntityManager, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _contactTable = [[MKMContactTable alloc] init];
        _userTable = [[MKMUserTable alloc] init];
        
        _groupTable = [[MKMGroupTable alloc] init];
        _memberTable = [[MKMMemberTable alloc] init];
    }
    return self;
}

- (void)addContact:(MKMContact *)contact {
    MKMAddress *address = contact.ID.address;
    NSAssert(address, @"address error");
    if (address.isValid) {
        [_contactTable setObject:contact forKey:address];
    }
}

- (void)addUser:(MKMUser *)user {
    MKMAddress *address = user.ID.address;
    NSAssert(address, @"address error");
    if (address.isValid) {
        [_userTable setObject:user forKey:address];
    }
}

- (void)addGroup:(MKMGroup *)group {
    MKMAddress *address = group.ID.address;
    NSAssert(address, @"address error");
    if (address.isValid) {
        [_groupTable setObject:group forKey:address];
    }
}

- (void)addMember:(MKMMember *)member {
    MKMAddress *gAddr = member.groupID.address;
    MKMAddress *uAddr = member.ID.address;
    NSAssert(gAddr, @"group address error");
    NSAssert(uAddr, @"address error");
    if (gAddr.isValid && uAddr.isValid) {
        MKMMembers *list = [_memberTable objectForKey:gAddr];
        if (!list) {
            list = [[MKMMembers alloc] init];
            [_memberTable setObject:list forKey:gAddr];
        }
        [list setObject:member forKey:uAddr];
    }
}

- (void)reduceMemory {
    reduce_table(_contactTable);
    reduce_table(_userTable);
    reduce_table(_groupTable);
    reduce_table(_memberTable);
}

#pragma mark - MKMEntityDelegate

- (MKMContact *)contactWithID:(const MKMID *)ID {
    MKMContact *contact = [_contactTable objectForKey:ID.address];
    if (!contact) {
        NSAssert(_delegate, @"delegate not set");
        contact = [_delegate contactWithID:ID];
        [self addContact:contact];
    }
    return contact;
}

- (MKMUser *)userWithID:(const MKMID *)ID {
    MKMUser *user = [_userTable objectForKey:ID.address];
    if (!user) {
        NSAssert(_delegate, @"delegate not set");
        user = [_delegate userWithID:ID];
        [self addUser:user];
    }
    return user;
}

- (MKMGroup *)groupWithID:(const MKMID *)ID {
    MKMGroup *group = [_groupTable objectForKey:ID.address];
    if (!group) {
        NSAssert(_delegate, @"delegate not set");
        group = [_delegate groupWithID:ID];
        [self addGroup:group];
    }
    return group;
}

- (MKMMember *)memberWithID:(const MKMID *)ID groupID:(const MKMID *)gID {
    MKMMembers *list = [_memberTable objectForKey:gID.address];
    MKMMember *member = [list objectForKey:ID.address];
    if (!member) {
        NSAssert(_delegate, @"delegate not set");
        member = [_delegate memberWithID:ID groupID:gID];
        [self addMember:member];
    }
    return member;
}

//#pragma mark - Meta
//
//- (MKMMeta *)metaForID:(const MKMID *)ID {
//    MKMMeta *meta = [_metaTable objectForKey:ID.address];
//    if (!meta && _dataSource) {
//        meta = [_dataSource metaForEntityID:ID];
//        if ([meta matchID:ID]) {
//            [_metaTable setObject:meta forKey:ID.address];
//        } else {
//            meta = nil;
//        }
//    }
//    return meta;
//}
//
//- (void)setMeta:(MKMMeta *)meta forID:(const MKMID *)ID {
//    if ([meta matchID:ID]) {
//        // set meta
//        [_metaTable setObject:meta forKey:ID.address];
//    }
//}
//
//- (void)sendMetaForID:(const MKMID *)ID {
//    MKMMeta *meta = [_metaTable objectForKey:ID.address];
//    if (meta && _delegate) {
//        // send out onto the network
//        [_delegate entityID:ID sendMeta:meta];
//    }
//}
//
//#pragma mark - History
//
//- (MKMHistory *)historyForID:(const MKMID *)ID {
//    MKMHistory *history = [_historyTable objectForKey:ID.address];
//    if (!history && _dataSource) {
//        history = [_dataSource historyForEntityID:ID];
//        if ([history matchID:ID]) {
//            [_historyTable setObject:history forKey:ID.address];
//        } else {
//            history = nil;
//        }
//    }
//    return history;
//}
//
//- (void)setHistory:(MKMHistory *)history forID:(const MKMID *)ID {
//    MKMHistory *old = [_historyTable objectForKey:ID.address];
//    if (history.count > old.count && [history matchID:ID]) {
//        // only update longest history
//        [_historyTable setObject:history forKey:ID.address];
//    }
//}
//
//- (void)sendHistoryForID:(const MKMID *)ID {
//    MKMHistory *history = [_historyTable objectForKey:ID.address];
//    if (history && _delegate) {
//        // only sendout longest history
//        [_delegate entityID:ID sendHistory:history];
//    }
//}
//
//- (void)sendHistoryRecord:(MKMHistoryRecord *)record
//                    forID:(const MKMID *)ID {
//    if (record && _delegate) {
//        [_delegate entityID:ID sendHistoryRecord:record];
//    }
//}

@end
