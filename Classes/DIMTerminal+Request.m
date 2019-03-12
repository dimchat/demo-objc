//
//  DIMTerminal+Request.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMServer.h"
#import "DIMTerminal+Request.h"

@implementation DIMTerminal (Command)

- (void)sendContent:(DIMMessageContent *)content to:(const DIMID *)receiver {
    if (!self.currentUser) {
        NSLog(@"not login, drop message content: %@", content);
        // TODO: save the message content in waiting queue
        return ;
    }
    DKDTransceiverCallback callback;
    callback = ^(const DKDReliableMessage *rMsg,
                 const NSError *error) {
        if (error) {
            NSLog(@"send content error: %@", error);
        } else {
            NSLog(@"sent content: %@ -> %@", content, rMsg);
        }
    };
    DIMTransceiver *trans = [DIMTransceiver sharedInstance];
    [trans sendMessageContent:content
                         from:self.currentUser.ID
                           to:receiver
                         time:nil
                     callback:callback];
}

- (void)sendCommand:(DIMCommand *)cmd {
    if (!_currentStation) {
        NSLog(@"not connect, drop command: %@", cmd);
        // TODO: save the command in waiting queue
        return ;
    }
    [self sendContent:cmd to:_currentStation.ID];
}

- (void)sendMessage:(DKDInstantMessage *)msg {
    NSAssert([msg.envelope.sender isEqual:self.currentUser.ID], @"sender error: %@", msg);
    [self sendContent:msg.content to:msg.envelope.receiver];
}

#pragma mark -

- (void)login:(DIMUser *)user {
    if (!user || [self.currentUser isEqual:user]) {
        NSLog(@"user not change");
        return ;
    }
    
    // clear session
    _session = nil;
    
    NSLog(@"logout: %@", self.currentUser);
    self.currentUser = user;
    NSLog(@"login: %@", user);
    
    // add to the list of this client
    if (user && ![_users containsObject:user]) {
        [_users addObject:user];
    }
}

- (void)postProfile:(DIMProfile *)profile meta:(nullable const DIMMeta *)meta {
    if (!profile) {
        return ;
    }
    const DIMID *ID = self.currentUser.ID;
    if (![profile.ID isEqual:ID]) {
        NSAssert(false, @"profile ID not match: %@, %@", ID, profile.ID);
        return ;
    }
    DIMPrivateKey *SK = self.currentUser.privateKey;
    
    DIMProfileCommand *cmd;
    cmd = [[DIMProfileCommand alloc] initWithID:ID
                                           meta:meta
                                     privateKey:SK
                                        profile:profile];
    [self sendCommand:cmd];
}

- (void)queryMetaForID:(const DIMID *)ID {
    DIMMetaCommand *cmd;
    cmd = [[DIMMetaCommand alloc] initWithID:ID
                                        meta:nil];
    [self sendCommand:cmd];
}

- (void)queryProfileForID:(const DIMID *)ID {
    DIMProfileCommand *cmd;
    cmd = [[DIMProfileCommand alloc] initWithID:ID
                                           meta:nil
                                        profile:nil
                                      signature:nil];
    [self sendCommand:cmd];
}

- (void)queryOnlineUsers {
    DIMCommand *cmd;
    cmd = [[DIMCommand alloc] initWithCommand:@"users"];
    [self sendCommand:cmd];
}

- (void)searchUsersWithKeywords:(const NSString *)keywords {
    DIMCommand *cmd = [[DIMCommand alloc] initWithCommand:@"search"];
    [cmd setObject:keywords forKey:@"keywords"];
    [self sendCommand:cmd];
}

@end
