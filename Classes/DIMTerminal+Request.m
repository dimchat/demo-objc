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

@implementation DIMTerminal (Packing)

- (nullable DIMInstantMessage *)sendContent:(DIMContent *)content
                                         to:(const DIMID *)receiver {
    if (!self.currentUser) {
        NSLog(@"not login, drop message content: %@", content);
        // TODO: save the message content in waiting queue
        return nil;
    }
    if (!DIMMetaForID(receiver)) {
        // TODO: check profile.key
        NSLog(@"cannot get public key for receiver: %@", receiver);
        [self queryMetaForID:receiver];
        // TODO: save the message content in waiting queue
        return nil;
    }
    const DIMID *sender = self.currentUser.ID;
    
    // make instant message
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:content
                                               sender:sender
                                             receiver:receiver
                                                 time:nil];
    // callback
    DIMTransceiverCallback callback;
    callback = ^(const DKDReliableMessage *rMsg, const NSError *error) {
        const NSString *name = nil;
        if (error) {
            NSLog(@"send message error: %@", error);
            name = kNotificationName_SendMessageFailed;
            iMsg.state = DIMMessageState_Error;
            iMsg.error = [error localizedDescription];
        } else {
            NSLog(@"sent message: %@ -> %@", iMsg, rMsg);
            name = kNotificationName_MessageSent;
            iMsg.state = DIMMessageState_Accepted;
        }
        
        NSDictionary *info = @{@"message": iMsg};
        [NSNotificationCenter postNotificationName:name
                                            object:self
                                          userInfo:info];
    };
    // send out
    DIMTransceiver *trans = [DIMTransceiver sharedInstance];
    if ([trans sendInstantMessage:iMsg callback:callback dispersedly:YES]) {
        return iMsg;
    } else {
        NSLog(@"failed to send message: %@", iMsg);
        return nil;
    }
}

- (nullable DIMInstantMessage *)sendCommand:(DIMCommand *)cmd {
    if (!_currentStation) {
        NSLog(@"not connect, drop command: %@", cmd);
        // TODO: save the command in waiting queue
        return nil;
    }
    return [self sendContent:cmd to:_currentStation.ID];
}

@end

@implementation DIMTerminal (Request)

- (BOOL)login:(DIMUser *)user {
    if (!user || [self.currentUser isEqual:user]) {
        NSLog(@"user not change");
        return NO;
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
    return YES;
}

- (void)onHandshakeAccepted:(const NSString *)session {
    // post profile
    DIMProfile *profile = DIMProfileForID(self.currentUser.ID);
    if (profile) {
        [self postProfile:profile meta:nil];
    }
}

- (nullable DIMInstantMessage *)postProfile:(DIMProfile *)profile
                                       meta:(nullable const DIMMeta *)meta {
    const DIMID *ID = self.currentUser.ID;
    if (![profile.ID isEqual:ID]) {
        NSAssert(false, @"profile ID not match: %@, %@", ID, profile.ID);
        return nil;
    }
    DIMCommand *cmd = [[DIMProfileCommand alloc] initWithID:ID meta:meta profile:profile];
    return [self sendCommand:cmd];
}

- (nullable DIMInstantMessage *)queryMetaForID:(const DIMID *)ID {
    DIMCommand *cmd = [[DIMMetaCommand alloc] initWithID:ID meta:nil];
    return [self sendCommand:cmd];
}

- (nullable DIMInstantMessage *)queryProfileForID:(const DIMID *)ID {
    DIMCommand *cmd = [[DIMProfileCommand alloc] initWithID:ID meta:nil profile:nil];
    return [self sendCommand:cmd];
}

- (nullable DIMInstantMessage *)queryOnlineUsers {
    DIMCommand *cmd = [[DIMCommand alloc] initWithCommand:@"users"];
    return [self sendCommand:cmd];
}

- (nullable DIMInstantMessage *)searchUsersWithKeywords:(const NSString *)keywords {
    DIMCommand *cmd = [[DIMCommand alloc] initWithCommand:@"search"];
    [cmd setObject:keywords forKey:@"keywords"];
    return [self sendCommand:cmd];
}

@end
