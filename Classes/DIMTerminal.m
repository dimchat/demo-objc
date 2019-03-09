//
//  DIMTerminal.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MarsGate/MarsGate.h>

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DIMServer.h"
#import "DIMTerminal+Request.h"
#import "DIMTerminal+Response.h"

#import "DIMTerminal.h"

@interface DIMTerminal ()

@property (strong, nonatomic) NSMutableArray<DIMUser *> *users;

@end

@implementation DIMTerminal

- (instancetype)init {
    if (self = [super init]) {
        _users = [[NSMutableArray alloc] init];
        
        _currentStation = nil;
        _session = nil;
    }
    return self;
}

- (NSString *)userAgent {
    return @"DIMP/1.0 (iPad; U; iOS 11.4; zh-CN) DIMCoreKit/1.0 (Terminal, like WeChat) DIM-by-GSP/1.0.1";
}

#pragma mark - User(s)

- (DIMUser *)currentUser {
    return _currentStation.currentUser;
}

- (void)setCurrentUser:(DIMUser *)user {
    _currentStation.currentUser = user;
    if (user && ![_users containsObject:user]) {
        // insert the user to the first
        [_users insertObject:user atIndex:0];
    }
}

- (void)addUser:(DIMUser *)user {
    if (user && ![_users containsObject:user]) {
        [_users addObject:user];
    }
    // check current user
    if (!_currentStation.currentUser) {
        _currentStation.currentUser = user;
    }
}

- (void)removeUser:(DIMUser *)user {
    if ([_users containsObject:user]) {
        [_users removeObject:user];
    }
    // check current user
    if ([_currentStation.currentUser isEqual:user]) {
        _currentStation.currentUser = _users.firstObject;
    }
}

#pragma mark DIMStationDelegate

- (void)station:(nonnull const DIMStation *)server didReceivePackage:(nonnull const NSData *)data {
    DIMTransceiver *trans = [DIMTransceiver sharedInstance];
    
    // decode
    NSString *json = [data UTF8String];
    DIMReliableMessage *rMsg;
    rMsg = [[DKDReliableMessage alloc] initWithJSONString:json];
    
    // check sender
    const DIMID *sender = rMsg.envelope.sender;
    const DIMMeta *meta = MKMMetaForID(sender);
    if (!meta) {
        meta = rMsg.meta;
        if (!meta) {
            NSLog(@"meta for %@ not found, query from the network...", sender);
            // TODO: insert the message to a temporary queue to waiting meta
            return [self queryMetaForID:sender];
        }
    }
    
    // check receiver
    const DIMID *receiver = rMsg.envelope.receiver;
    DIMUser *user = self.currentUser;
    if (MKMNetwork_IsCommunicator(receiver.type)) {
        if ([receiver isEqual:user.ID]) {
            NSLog(@"got message for current user: %@", user);
        } else {
            for (DIMUser *item in self.users) {
                if ([receiver isEqual:item.ID]) {
                    user = item;
                    NSLog(@"got message for user: %@", user);
                }
            }
        }
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        DIMGroup *group = MKMGroupWithID(receiver);
        if ([group existsMember:receiver]) {
            NSLog(@"got group message for current user: %@", user);
        } else {
            for (DIMUser *item in self.users) {
                if ([group existsMember:item.ID]) {
                    user = item;
                    NSLog(@"got group message for user: %@", user);
                }
            }
        }
    } else {
        NSAssert(false, @"receiver type error: %@", receiver);
    }
    
    // trans to instant message
    DKDInstantMessage *iMsg;
    iMsg = [trans verifyAndDecryptMessage:rMsg forUser:user];
    
    // process commands
    DIMMessageContent *content = iMsg.content;
    if (content.type == DIMMessageType_Command) {
        NSString *command = content.command;
        if ([command isEqualToString:@"handshake"]) {
            // handshake
            return [self processHandshakeMessageContent:content];
        } else if ([command isEqualToString:@"meta"]) {
            // query meta response
            return [self processMetaMessageContent:content];
        } else if ([command isEqualToString:@"profile"]) {
            // query profile response
            return [self processProfileMessageContent:content];
        } else if ([command isEqualToString:@"users"]) {
            // query online users response
            return [self processOnlineUsersMessageContent:content];
        } else if ([command isEqualToString:@"search"]) {
            // search users response
            return [self processSearchUsersMessageContent:content];
        } else {
            NSLog(@"!!! unknown command: %@, sender: %@, message content: %@",
                  command, sender, content);
            return ;
        }
    }
    
    if (MKMNetwork_IsStation(sender.type)) {
        NSLog(@"*** message from station: %@", content);
        //return ;
    }
    
    // normal message, let the clerk to deliver it
    DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
    [clerk saveMessage:iMsg];
}

@end

@implementation DIMTerminal (GroupEntity)

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
