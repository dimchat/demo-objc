//
//  DIMAmanuensis.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMReceiptCommand.h"

#import "DIMBarrack.h"
#import "DIMConversation.h"

#import "DIMAmanuensis.h"

@interface DIMAmanuensis () {
    
    NSMutableDictionary<const DIMAddress *, DIMConversation *> *_conversations;
}

@end

@implementation DIMAmanuensis

SingletonImplementations(DIMAmanuensis, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        _conversations = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setConversationDataSource:(id<DIMConversationDataSource>)dataSource {
    if (dataSource) {
        NSMutableDictionary<const DIMAddress *, DIMConversation *> *list;
        list = [_conversations copy];
        // update exists chat boxes
        DIMConversation *chatBox;
        for (id addr in list) {
            chatBox = [list objectForKey:addr];
            if (chatBox.dataSource == nil) {
                chatBox.dataSource = dataSource;
            }
        }
    }
    _conversationDataSource = dataSource;
}

- (void)setConversationDelegate:(id<DIMConversationDelegate>)delegate {
    if (delegate) {
        NSMutableDictionary<const DIMAddress *, DIMConversation *> *list;
        list = [_conversations copy];
        // update exists chat boxes
        DIMConversation *chatBox;
        for (id addr in list) {
            chatBox = [list objectForKey:addr];
            if (chatBox.delegate == nil) {
                chatBox.delegate = delegate;
            }
        }
    }
    _conversationDelegate = delegate;
}

- (DIMConversation *)conversationWithID:(const DIMID *)ID {
    DIMConversation *chatBox = [_conversations objectForKey:ID.address];
    if (!chatBox) {
        if (_conversationDelegate) {
            // create by delegate
            chatBox = [_conversationDelegate conversationWithID:ID];
        }
        if (!chatBox) {
            // create directly if we can find the entity
            // get entity with ID
            DIMEntity *entity = nil;
            if (MKMNetwork_IsCommunicator(ID.type)) {
                entity = DIMAccountWithID(ID);
            } else if (MKMNetwork_IsGroup(ID.type)) {
                entity = DIMGroupWithID(ID);
            }
            NSAssert(entity, @"ID error: %@", ID);
            if (entity) {
                // create new conversation with entity(Account/Group)
                chatBox = [[DIMConversation alloc] initWithEntity:entity];
            }
        }
        NSAssert(chatBox, @"failed to create conversation: %@", ID);
        [self addConversation:chatBox];
    }
    return chatBox;
}

- (void)addConversation:(DIMConversation *)chatBox {
    NSAssert([chatBox.ID isValid], @"conversation invalid: %@", chatBox.ID);
    // check data source
    if (chatBox.dataSource == nil) {
        chatBox.dataSource = _conversationDataSource;
    }
    // check delegate
    if (chatBox.delegate == nil) {
        chatBox.delegate = _conversationDelegate;
    }
    const DIMID *ID = chatBox.ID;
    [_conversations setObject:chatBox forKey:ID.address];
}

- (void)removeConversation:(DIMConversation *)chatBox {
    const DIMID *ID = chatBox.ID;
    [_conversations removeObjectForKey:ID.address];
}

@end

@implementation DIMAmanuensis (Message)

- (BOOL)saveMessage:(DIMInstantMessage *)iMsg {
    NSLog(@"saving message: %@", iMsg);
    
    DIMConversation *chatBox = nil;
    
    DIMEnvelope *env = iMsg.envelope;
    const DIMID *sender = [DIMID IDWithID:env.sender];
    const DIMID *receiver = [DIMID IDWithID:env.receiver];
    const DIMID *groupID = [DIMID IDWithID:iMsg.content.group];
    
    if (MKMNetwork_IsGroup(receiver.type)) {
        // group chat, get chat box with group ID
        chatBox = [self conversationWithID:receiver];
    } else if (groupID) {
        // group chat, get chat box with group ID
        chatBox = [self conversationWithID:groupID];
    } else {
        // personal chat, get chat box with contact ID
        chatBox = [self conversationWithID:sender];
    }
    
    NSAssert(chatBox, @"chat box not found for message: %@", iMsg);
    return [chatBox insertMessage:iMsg];
}

- (BOOL)saveReceipt:(DKDInstantMessage *)iMsg {
    DIMMessageContent *content = iMsg.content;
    if (content.type != DIMMessageType_Command ||
        ![content.command isEqualToString:DKDSystemCommand_Receipt]) {
        NSAssert(false, @"this is not a receipt: %@", iMsg);
        return NO;
    }
    DIMReceiptCommand *receipt;
    receipt = [[DIMReceiptCommand alloc] initWithDictionary:content];
    NSLog(@"saving receipt: %@", receipt);
    
    DIMConversation *chatBox = nil;
    
    // NOTE: this is the receipt's commander,
    //       it can be a station, or the original message's receiver
    const DIMID *sender = [DIMID IDWithID:iMsg.envelope.sender];
    
    // NOTE: this is the original message's receiver
    const DIMID *receiver = [DIMID IDWithID:receipt.envelope.receiver];
    
    // FIXME: only the real receiver will know the exact message detail, so
    //        the station may not know if this is a group message.
    //        maybe we should try another way to search the exact conversation.
    const DIMID *groupID = [DIMID IDWithID:receipt.group];
    
    if (receiver == nil) {
        NSLog(@"receiver not found, it's not a receipt for instant message");
        return NO;
    }
    
    if (groupID) {
        // group chat, get chat box with group ID
        chatBox = [self conversationWithID:groupID];
    } else {
        // personal chat, get chat box with contact ID
        chatBox = [self conversationWithID:receiver];
    }
    
    NSAssert(chatBox, @"chat box not found for receipt: %@", receipt);
    DIMInstantMessage *targetMessage;
    targetMessage = [self conversation:chatBox messageMatchReceipt:receipt];
    if (targetMessage) {
        if ([sender isEqual:receiver]) {
            // the receiver's client feedback
            if ([receipt.message containsString:@"read"]) {
                targetMessage.state = DIMMessageState_Read;
            } else {
                targetMessage.state = DIMMessageState_Arrived;
            }
        } else if (MKMNetwork_IsStation(sender.type)) {
            // delivering or delivered to receiver (station said)
            if ([receipt.message containsString:@"delivered"]) {
                targetMessage.state = DIMMessageState_Delivered;
            } else {
                targetMessage.state = DIMMessageState_Delivering;
            }
        } else {
            NSAssert(false, @"unexpect receipt sender: %@", sender);
            return NO;
        }
        return YES;
    }
    
    NSLog(@"target message not found for receipt: %@", receipt);
    return NO;
}

- (nullable DIMInstantMessage *)conversation:(DIMConversation *)chatBox
                         messageMatchReceipt:(DIMReceiptCommand *)receipt {
    DIMInstantMessage *iMsg = nil;
    NSInteger count = [chatBox numberOfMessage];
    for (NSInteger index = count - 1; index >= 0; --index) {
        iMsg = [chatBox messageAtIndex:index];
        if ([iMsg matchReceipt:receipt]) {
            return iMsg;
        }
    }
    return nil;
}

@end
