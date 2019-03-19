//
//  DIMTerminal+Request.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSNotificationCenter+Extension.h"

#import "DIMServer.h"
#import "DIMTerminal+Request.h"

const NSString *kNotificationName_MessageSent       = @"MessageSent";
const NSString *kNotificationName_SendMessageFailed = @"SendMessageFailed";

@implementation DIMTerminal (Request)

- (void)sendContent:(DIMMessageContent *)content to:(const DIMID *)receiver {
    if (!self.currentUser) {
        NSLog(@"not login, drop message content: %@", content);
        // TODO: save the message content in waiting queue
        return ;
    }
    if (!DIMPublicKeyForID(receiver)) {
        NSLog(@"cannot get public key for receiver: %@", receiver);
        [self queryMetaForID:receiver];
        // TODO: save the message content in waiting queue
        return ;
    }
    // make instant message
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:content
                                               sender:self.currentUser.ID
                                             receiver:receiver
                                                 time:nil];
    [self sendMessage:iMsg];
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
    NSAssert([self.currentUser.ID isEqual:msg.envelope.sender], @"sender error: %@", msg);
    // callback
    DIMTransceiverCallback callback;
    callback = ^(const DKDReliableMessage *rMsg, const NSError *error) {
        const NSString *name = nil;
        NSDictionary *info = nil;
        if (error) {
            NSLog(@"send message error: %@", error);
            name = kNotificationName_SendMessageFailed;
            info = @{@"message": msg, @"error": error};
        } else {
            NSLog(@"sent message: %@ -> %@", msg, rMsg);
            name = kNotificationName_MessageSent;
            info = @{@"message": msg};
        }
        [NSNotificationCenter postNotificationName:name
                                            object:self
                                          userInfo:info];
    };
    DIMTransceiver *trans = [DIMTransceiver sharedInstance];
    [trans sendInstantMessage:msg callback:callback dispersedly:YES];
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
