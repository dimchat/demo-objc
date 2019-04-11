//
//  DIMTerminal.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MarsGate/MarsGate.h>

#import "NSObject+JsON.h"

#import "DIMServer.h"
#import "DIMTerminal+Request.h"
#import "DIMTerminal+Response.h"
#import "DIMTerminal+Group.h"

#import "DIMTerminal.h"

@interface DIMTerminal ()

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

- (NSString *)language {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    return languages.firstObject;
}

#pragma mark - User(s)

- (NSArray<DIMUser *> *)users {
    return [_users copy];
}

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
    NSAssert([user.ID isValid], @"invalid user: %@", user);
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
    const DIMID *sender = [DIMID IDWithID:rMsg.envelope.sender];
    const DIMMeta *meta = DIMMetaForID(sender);
    if (!meta) {
        meta = [DIMMeta metaWithMeta:rMsg.meta];
        if (!meta) {
            NSLog(@"meta for %@ not found, query from the network...", sender);
            [self queryMetaForID:sender];
            // TODO: insert the message to a temporary queue to waiting meta
            return ;
        }
    }
    
    // check receiver
    const DIMID *receiver = [DIMID IDWithID:rMsg.envelope.receiver];
    DIMUser *user = nil;
    if (MKMNetwork_IsGroup(receiver.type)) {
        NSAssert(rMsg.group == nil || [[DIMID IDWithID:rMsg.group] isEqual:receiver],
                 @"group error: %@ != %@", receiver, rMsg.group);
        // FIXME: maybe other user?
        user = self.currentUser;
        receiver = user.ID;
    } else if ([self.currentUser.ID isEqual:receiver]) {
        user = self.currentUser;
    } else {
        for (DIMUser *item in self.users) {
            if ([item.ID isEqual:receiver]) {
                user = item;
                NSLog(@"got new message for: %@", item.ID);
                break;
            }
        }
    }
    if (!user) {
        NSAssert(false, @"!!! wrong recipient: %@", receiver);
        return ;
    }
    
    // trans to instant message
    DKDInstantMessage *iMsg;
    iMsg = [trans verifyAndDecryptMessage:rMsg users:self.users];
    
    // process commands
    DIMMessageContent *content = iMsg.content;
    if (content.type == DIMMessageType_Command) {
        NSString *command = content.command;
        if ([command isEqualToString:DKDSystemCommand_Handshake]) {
            // handshake
            return [self processHandshakeMessageContent:content];
        } else if ([command isEqualToString:DKDSystemCommand_Meta]) {
            // query meta response
            return [self processMetaMessageContent:content];
        } else if ([command isEqualToString:DKDSystemCommand_Profile]) {
            // query profile response
            return [self processProfileMessageContent:content];
        } else if ([command isEqualToString:@"users"]) {
            // query online users response
            return [self processOnlineUsersMessageContent:content];
        } else if ([command isEqualToString:@"search"]) {
            // search users response
            return [self processSearchUsersMessageContent:content];
        } else if ([command isEqualToString:DKDSystemCommand_Receipt]) {
            // receipt
            DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
            if ([clerk saveReceipt:iMsg]) {
                NSLog(@"target message state updated with receipt: %@", content);
            }
            return ;
        }
        NSLog(@"!!! unknown command: %@, sender: %@, message content: %@",
              command, sender, content);
        // NOTE: let the message processor to do the job
        //return ;
    } else if (content.type == DIMMessageType_History) {
        const DIMID *groupID = [DIMID IDWithID:content.group];
        if (groupID) {
            if (![self checkGroupCommand:content commander:sender]) {
                NSLog(@"!!! error group history command from %@: %@", sender, content);
                return ;
            }
        }
        // NOTE: let the message processor to do the job
        //return ;
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
