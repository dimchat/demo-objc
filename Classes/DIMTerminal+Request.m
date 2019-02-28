//
//  DIMTerminal+Request.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMTerminal+Request.h"

@implementation DIMTerminal (Command)

- (void)sendContent:(DKDMessageContent *)content to:(MKMID *)receiver {
    if (!_currentUser) {
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
                         from:_currentUser.ID
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
    NSAssert([msg.envelope.sender isEqual:_currentUser.ID], @"sender error: %@", msg);
    [self sendContent:msg.content to:msg.envelope.receiver];
}

#pragma mark -

- (void)login:(DIMUser *)user {
    if ([_currentUser isEqual:user]) {
        NSLog(@"user not change");
        return ;
    }
    
    // logout current user first
    NSLog(@"logout: %@", _currentUser);
    _session = nil;
    
    self.currentUser = user;
    
    // switch state for re-login
    _state = DIMTerminalState_Init;
    NSLog(@"login: %@", _currentUser);
}

- (void)handshake {
    DIMTransceiver *trans = [DIMTransceiver sharedInstance];
    
    DIMHandshakeCommand *cmd;
    cmd = [[DIMHandshakeCommand alloc] initWithSessionKey:_session];
    // TODO: insert task to front of the sending queue
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:cmd
                                               sender:_currentUser.ID
                                             receiver:_currentStation.ID
                                                 time:nil];
    DIMReliableMessage *rMsg;
    rMsg = [trans encryptAndSignMessage:iMsg];
    
    // first handshake?
    if (cmd.state == DIMHandshake_Start) {
        rMsg.meta = MKMMetaForID(_currentUser.ID);
    }
    
    DKDTransceiverCallback callback;
    callback = ^(const DKDReliableMessage * rMsg, const NSError * _Nullable error) {
        if (error) {
            NSLog(@"send handshake command error: %@", error);
        } else {
            NSLog(@"sent handshake command: %@ -> %@", cmd, rMsg);
        }
    };
    
    // TODO: insert the task in front of the sending queue
    [trans sendReliableMessage:rMsg callback:callback];
}

- (void)postProfile:(DIMProfile *)profile meta:(nullable DIMMeta *)meta {
    if (!profile) {
        return ;
    }
    if (![profile.ID isEqual:_currentUser.ID]) {
        NSAssert(false, @"profile ID not match");
        return ;
    }
    
    DIMProfileCommand *cmd;
    cmd = [[DIMProfileCommand alloc] initWithID:_currentUser.ID
                                           meta:meta
                                     privateKey:_currentUser.privateKey
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
