//
//  DIMClient+Message.m
//  DIM
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMConnection.h"

#import "DIMBarrack.h"
#import "DIMAmanuensis.h"

#import "DIMClient+Message.h"

@implementation DIMClient (Message)

- (BOOL)sendMessage:(DIMCertifiedMessage *)cMsg {
    NSAssert(cMsg.signature, @"signature cannot be empty");
    DIMConnection *connection = self.currentConnection;
    if (connection.isConnected != YES) {
        NSLog(@"connect first");
        return NO;
    }
    NSData *jsonData = [cMsg jsonData];
    return [connection sendData:jsonData];
}

- (void)recvMessage:(DIMInstantMessage *)iMsg {
    NSLog(@"saving message: %@", iMsg);
    
    DIMBarrack *barrack = [DIMBarrack sharedInstance];
    
    DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
    DIMConversation *chat = nil;
    
    DIMEnvelope *env = iMsg.envelope;
    MKMID *sender = env.sender;
    MKMID *receiver = env.receiver;
    
    if ([receiver isEqual:self.currentUser.ID]) {
        // personal chat, get chatroom with contact ID
        chat = [clerk conversationWithID:sender];
        if (!chat) {
            DIMContact *contact = [barrack contactForID:sender];
            chat = [[DIMConversation alloc] initWithEntity:contact];
            [clerk setConversation:chat];
        }
    } else if (receiver.address.network == MKMNetwork_Group) {
        // group chat, get chatroom with group ID
        chat = [clerk conversationWithID:receiver];
        if (!chat) {
            DIMGroup *group = [barrack groupForID:receiver];
            chat = [[DIMConversation alloc] initWithEntity:group];
            [clerk setConversation:chat];
        }
    }
    NSAssert(chat, @"chat room not found");
    
    [chat insertMessage:iMsg];
}

@end
