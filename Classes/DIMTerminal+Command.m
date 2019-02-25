//
//  DIMTerminal+Command.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMTerminal+Command.h"

@implementation DIMTerminal (Command)

- (void)sendContent:(DKDMessageContent *)content to:(MKMID *)receiver {
    if (!_currentUser) {
        NSLog(@"not login yet");
        return ;
    }
    DKDTransceiverCallback callback;
    callback = ^(const DKDReliableMessage *rMsg,
                 const NSError *error) {
        if (error) {
            NSLog(@"send content error: %@", error);
        } else {
            NSLog(@"send content %@ -> %@", content, rMsg);
        }
    };
    DIMTransceiver *trans = [DIMTransceiver sharedInstance];
    [trans sendMessageContent:content
                         from:_currentUser.ID
                           to:receiver
                         time:nil
                     callback:callback];
}

- (void)sendMessage:(DKDInstantMessage *)msg {
    NSAssert([msg.envelope.sender isEqual:_currentUser.ID], @"sender error: %@", msg);
    [self sendContent:msg.content to:msg.envelope.receiver];
}

- (void)sendCommand:(DIMCommand *)cmd {
    [self sendContent:cmd to:_currentStation.ID];
}

#pragma mark -

- (void)login:(DIMUser *)user {
    if (_currentUser) {
        // TODO: logout current user first
        NSLog(@"logout: %@", _currentUser);
    }
    
    self.currentUser = user;
    
    // switch state for re-login
    _state = DIMTerminalState_Init;
}

- (void)handshake {
    DIMHandshakeCommand *cmd;
    cmd = [[DIMHandshakeCommand alloc] initWithSessionKey:_session];
    // TODO: insert task to front of the sending queue
    [self sendCommand:cmd];
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
