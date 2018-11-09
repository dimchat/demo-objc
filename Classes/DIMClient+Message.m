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
    
    DIMConversation *dialogBox = nil;
    
    DIMEnvelope *env = iMsg.envelope;
    MKMID *sender = env.sender;
    MKMID *receiver = env.receiver;
    
    if ([receiver isEqual:self.currentUser.ID]) {
        // personal chat, get chatroom with contact ID
        dialogBox = DIMConversationWithID(sender);
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        // group chat, get chatroom with group ID
        dialogBox = DIMConversationWithID(receiver);
    }
    NSAssert(dialogBox, @"dialogBox not found");
    
    [dialogBox insertMessage:iMsg];
}

@end
