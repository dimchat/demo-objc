//
//  DIMClient+Message.m
//  DIMC
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMStation.h"

#import "DIMConversation.h"
#import "DIMAmanuensis.h"

#import "DIMClient+Message.h"

@implementation DIMClient (Message)

- (BOOL)sendMessage:(const DIMCertifiedMessage *)cMsg {
    NSAssert(cMsg.signature, @"signature cannot be empty");
    NSData *data = [cMsg jsonData];
    // TODO: zip before sending the data if need
    
    NSAssert(_currentStation, @"set station first");
    return [_currentStation sendData:data];
}

- (void)recvMessage:(const DIMInstantMessage *)iMsg {
    NSLog(@"saving message: %@", iMsg);
    
    DIMConversation *chatBox = nil;
    
    DIMEnvelope *env = iMsg.envelope;
    MKMID *sender = env.sender;
    MKMID *receiver = env.receiver;
    
    if ([receiver isEqual:self.currentUser.ID]) {
        // personal chat, get chatroom with contact ID
        chatBox = DIMConversationWithID(sender);
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        // group chat, get chatroom with group ID
        chatBox = DIMConversationWithID(receiver);
    }
    NSAssert(chatBox, @"conversation not found");
    
    [chatBox insertMessage:iMsg];
}

@end
