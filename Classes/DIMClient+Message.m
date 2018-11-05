//
//  DIMClient+Message.m
//  DIMC
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMStation.h"

#import "DIMAmanuensis.h"

#import "DIMClient+Message.h"

@implementation DIMClient (Message)

- (BOOL)sendMessage:(const DIMCertifiedMessage *)cMsg {
    NSAssert(cMsg.signature, @"signature cannot be empty");
    // TODO:
    
    return YES;
}

- (void)recvMessage:(const DIMInstantMessage *)iMsg {
    NSLog(@"saving message: %@", iMsg);
    
    DIMConversation *chatroom = nil;
    
    DIMEnvelope *env = iMsg.envelope;
    MKMID *sender = env.sender;
    MKMID *receiver = env.receiver;
    
    if ([receiver isEqual:self.currentUser.ID]) {
        // personal chat, get chatroom with contact ID
        chatroom = DIMConversationWithID(sender);
    } else if (receiver.address.network == MKMNetwork_Group) {
        // group chat, get chatroom with group ID
        chatroom = DIMConversationWithID(receiver);
    }
    NSAssert(chatroom, @"chatroom room not found");
    
    [chatroom insertMessage:iMsg];
}

@end
