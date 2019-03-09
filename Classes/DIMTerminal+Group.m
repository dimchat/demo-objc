//
//  DIMTerminal+Group.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/9.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DIMTerminal+Group.h"

@implementation DIMTerminal (GroupManage)

- (void)sendOutGroupID:(const DIMID *)groupID
                  meta:(const DIMMeta *)meta
               profile:(const DIMProfile *)profile
               members:(const NSArray<const DIMID *> *)list {
    DIMUser *user = self.currentUser;
    DIMID *ID;
    
    // 1. send out meta & profile
    DIMPrivateKey *SK = user.privateKey;
    NSString *string = [profile jsonString];
    NSString *signature = [[SK sign:[string data]] base64Encode];
    
    DIMCommand *cmd;
    cmd = [[DIMProfileCommand alloc] initWithID:groupID
                                           meta:meta
                                        profile:string
                                      signature:signature];
    
    // 1.1. share to station
    [self sendCommand:cmd];
    
    // 1.2. send to each member
    for (ID in list) {
        if ([ID isEqual:user.ID]) {
            // ignore myself
            continue;
        }
        [self sendContent:cmd to:ID];
    }
    
    // 2. send out member list
    if (![list containsObject:user.ID]) {
        // add myself into the group members list
        NSMutableArray *mArray = [list mutableCopy];
        [mArray addObject:user.ID];
        list = mArray;
    }
    
    DIMMessageContent *ctx;
    ctx = [[DIMInviteCommand alloc] initWithGroup:groupID
                                          members:list];
    [ctx setObject:user.ID forKey:@"owner"];
    
    // 2.1. send to each member
    for (ID in list) {
        if ([ID isEqual:user.ID]) {
            // ignore myself
            continue;
        }
        [self sendContent:ctx to:ID];
    }
}

- (DIMGroup *)createGroupWithSeed:(const NSString *)seed
                             name:(const NSString *)name
                          members:(const NSArray<const MKMID *> *)list {
    DIMUser *user = self.currentUser;
    
    // generate group meta with current user's private key
    DIMMeta *meta = [[DIMMeta alloc] initWithSeed:seed
                                       privateKey:user.privateKey
                                        publicKey:nil
                                          version:MKMMetaDefaultVersion];
    // generate group ID
    const DIMID *ID = [meta buildIDWithNetworkID:MKMNetwork_Polylogue];
    // save meta for group ID
    DIMBarrack *barrack = [DIMBarrack sharedInstance];
    [barrack saveMeta:meta forEntityID:ID];
    
    // end out meta+profile command
    DIMProfile *profile;
    profile = [[DIMProfile alloc] initWithDictionary:@{@"ID":ID,
                                                       @"name":name,
                                                       }];
    NSLog(@"new group: %@, meta: %@, profile: %@", ID, meta, profile);
    [self sendOutGroupID:ID meta:meta profile:profile members:list];
    
    // create group
    DIMGroup *group = [[DIMGroup alloc] initWithID:ID];
    if (group) {
        // set barrack as data source
        group.dataSource = barrack;
    }
    return group;
}

- (BOOL)updateGroupWithID:(const MKMID *)ID
                     name:(const NSString *)name
                  members:(const NSArray<const MKMID *> *)list {
    DIMGroup *group = MKMGroupWithID(ID);
    const DIMMeta *meta = group.meta;
    if (![meta matchID:ID]) {
        NSAssert(false, @"meta not match: %@", ID);
        return NO;
    }
    DIMProfile *profile = MKMProfileForID(ID);
    if (profile) {
        profile.name = (NSString *)name;
    } else {
        profile = [[DIMProfile alloc] initWithDictionary:@{@"ID":ID,
                                                           @"name":name,
                                                           }];
    }
    NSLog(@"new group: %@, meta: %@, profile: %@", ID, meta, profile);
    [self sendOutGroupID:ID meta:meta profile:profile members:list];
    return YES;
}

@end

@implementation DIMTerminal (GroupHistory)

- (BOOL)processInviteMembersMessageContent:(DKDMessageContent *)content {
    // check owner
    DIMID *owner = [content objectForKey:@"owner"];
    owner = [DIMID IDWithID:owner];
    DIMPublicKey *PK = MKMPublicKeyForID(owner);
    
    const DIMID *groupID = content.group;
    const DIMMeta *meta = MKMMetaForID(groupID);
    if (![meta matchPublicKey:PK]) {
        NSLog(@"commander %@ not match the group.meta: %@", owner, meta);
        return NO;
    }
    
    NSArray *members = [content objectForKey:@"members"];
    if (members.count == 0) {
        NSLog(@"members is empty: %@", content);
        return NO;
    }
    
    NSLog(@"receive %lu member(s) for group: %@, list: %@", members.count, groupID, members);
    return YES;
}

@end
