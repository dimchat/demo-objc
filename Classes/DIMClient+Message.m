//
//  DIMClient+Message.m
//  DIM
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMStation.h"
#import "DIMConnection.h"

#import "DIMAmanuensis.h"

#import "DIMClient+Message.h"

@implementation DIMClient (Message)

- (BOOL)sendMessage:(const DIMCertifiedMessage *)cMsg {
    NSAssert(cMsg.signature, @"signature cannot be empty");
    DIMConnection *connection = self.currentConnection;
    if (connection.isConnected == NO) {
        // try to reconnect
        if ([self reconnect] == NO) {
            NSLog(@"failed to reconnect: %@", connection.target.host);
            return NO;
        }
    }
    NSData *jsonData = [cMsg jsonData];
    return [connection sendData:jsonData];
}

- (void)recvMessage:(const DIMInstantMessage *)iMsg {
    NSLog(@"saving message: %@", iMsg);
    
    DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
    DIMConversation *chatroom = nil;
    
    DIMEnvelope *env = iMsg.envelope;
    MKMID *sender = env.sender;
    MKMID *receiver = env.receiver;
    
    if ([receiver isEqual:self.currentUser.ID]) {
        // personal chat, get chatroom with contact ID
        chatroom = [clerk conversationWithID:sender];
    } else if (receiver.address.network == MKMNetwork_Group) {
        // group chat, get chatroom with group ID
        chatroom = [clerk conversationWithID:receiver];
    }
    NSAssert(chatroom, @"chatroom room not found");
    
    [chatroom insertMessage:iMsg];
}

@end
