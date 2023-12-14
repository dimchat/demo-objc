// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMGroupEmitter.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/13.
//

#import "DIMCommonFacebook.h"
#import "DIMCommonMessenger.h"

#import "DIMGroupDelegate.h"
#import "DIMGroupPacker.h"

#import "DIMGroupEmitter.h"

@interface DIMGroupEmitter ()

@property (strong, nonatomic) DIMGroupDelegate *delegate;
@property (strong, nonatomic) DIMGroupPacker *packer;

@end

@implementation DIMGroupEmitter

- (instancetype)initWithDelegate:(DIMGroupDelegate *)delegate {
    if (self = [self init]) {
        self.delegate = delegate;
        self.packer = [self createPacker];
    }
    return self;
}

- (DIMGroupPacker *)createPacker {
    return [[DIMGroupPacker alloc] initWithDelegate:self.delegate];
}

- (DIMCommonFacebook *)facebook {
    return [self.delegate facebook];
}

- (DIMCommonMessenger *)messenger {
    return [self.delegate messenger];
}

// private
- (void)attachGroupTimes:(id<DKDInstantMessage>)iMsg group:(id<MKMID>)gid {
    if ([iMsg.content conformsToProtocol:@protocol(DKDGroupCommand)]) {
        // no need to attach times for group command
        return;
    }
    id<MKMBulletin> doc = [self.facebook bulletinForID:gid];
    if (!doc) {
        NSAssert(false, @"failed to get bulletin document for group: %@", gid);
        return;
    }
    // attach group document time
    NSDate *lastDocTime = [doc time];
    if (lastDocTime) {
        [iMsg setDate:lastDocTime forKey:@"GDT"];
    } else {
        NSAssert(false, @"document error: %@", doc);
    }
    // attach group history time
    NSDate *lastHisTime = [self.facebook.archivist lastTimeOfHistoryForID:gid];
    if (lastHisTime) {
        [iMsg setDate:lastHisTime forKey:@"GHT"];
    } else {
        NSAssert(false, @"failed to get history time: %@", gid);
    }
}

- (id<DKDReliableMessage>)sendInstantMessage:(id<DKDInstantMessage>)iMsg
                                    priority:(NSInteger)prior {
    id<DKDContent> content = [iMsg content];
    id<MKMID> group = [content group];
    if (!group) {
        NSAssert(false, @"not a group message: %@", iMsg);
        return nil;
    }
    NSAssert([iMsg.receiver isEqual:group], @"group message error: %@", iMsg);
    
    // attach group document & history times
    // for the receiver to check whether group info synchronized
    [self attachGroupTimes:iMsg group:group];
    
    // TODO: if it's a file message
    //       please upload the file data first
    //       before calling this
    NSAssert(![content conformsToProtocol:@protocol(DKDFileContent)] ||
             ![content objectForKey:@"data"], @"content error: %@", content);
    
    //
    //  1. check group bots
    //
    NSArray<id<MKMID>> *bots = [self.delegate assistantsOfGroup:group];
    if ([bots count] > 0) {
        // group bots found, forward this message to any bot to let it split for me;
        // this can reduce my jobs.
        return [self _forwardMessage:iMsg
                           assistant:bots.firstObject
                               group:group
                            priority:prior];
    }
    
    //
    //  2. check group members
    //
    NSArray<id<MKMID>> *members = [self.delegate membersOfGroup:group];
    NSUInteger count = [members count];
    if (count == 0) {
        NSAssert(false, @"failed to get members for group: %@", group);
        return nil;
    }
    // no 'assistants' found in group's bulletin document?
    // split group messages and send to all members one by one
    if (count < DIM_SECRET_GROUP_LIMIT) {
        // it is a tiny group, split this message before encrypting and signing,
        // then send this group message to all members one by one
        NSUInteger success = [self _splitAndSendMessage:iMsg
                                                members:members
                                                  group:group
                                               priority:prior];
        NSLog(@"split %lu message(s) for group: %@", success, group);
        return nil;
    } else {
        NSLog(@"splitting message for %lu members of group: %@", count, group);
        // encrypt and sign this message first,
        // then split and send to all members one by one
        return [self _disperseMessage:iMsg
                              members:members
                                group:group
                             priority:prior];
    }
}

/**
 *  Encrypt & sign message, then forward to the bot
 */
- (id<DKDReliableMessage>)_forwardMessage:(id<DKDInstantMessage>)iMsg
                                assistant:(id<MKMID>)bid
                                    group:(id<MKMID>)gid
                                 priority:(NSInteger)prior {
    NSAssert([bid isUser] && [gid isGroup], @"ID error: %@, %@", bid, gid);
    // NOTICE: because group assistant (bot) cannot be a member of the group, so
    //         if you want to send a group command to any assistant, you must
    //         set the bot ID as 'receiver' and set the group ID in content;
    //         this means you must send it to the bot directly.
    DIMCommonMessenger *messenger = [self messenger];

    // group bots designated, let group bot to split the message, so
    // here must expose the group ID; this will cause the client to
    // use a "user-to-group" encrypt key to encrypt the message content,
    // this key will be encrypted by each member's public key, so
    // all members will received a message split by the group bot,
    // but the group bots cannot decrypt it.
    [iMsg setString:gid forKey:@"group"];
    
    //
    //  1. pack message
    //
    id<DKDReliableMessage> rMsg = [self.packer encryptAndSignMessage:iMsg];
    if (!rMsg) {
        NSAssert(false, @"failed to encrypt & sign message: %@ => %@", iMsg.sender, gid);
        return nil;
    }
    
    //
    //  2. forward the group message to any bot
    //
    id<DKDContent> content = DIMForwardContentCreate(@[rMsg]);
    DIMTransmitterResults *pair = [messenger sendContent:content
                                                  sender:nil
                                                receiver:bid
                                                priority:prior];
    if (!pair.second) {
        NSAssert(false, @"failed to forward message for group: %@, bot: %@", gid, bid);
    }
    
    // OK, return the forwading message
    return rMsg;
}

/**
 *  Encrypt & sign message, then disperse to all members
 */
- (id<DKDReliableMessage>)_disperseMessage:(id<DKDInstantMessage>)iMsg
                                   members:(NSArray<id<MKMID>> *)allMembers
                                     group:(id<MKMID>)gid
                                  priority:(NSInteger)prior {
    NSAssert([gid isGroup], @"group ID error: %@", gid);
    //NSAssert(![iMsg objectForKey:@"group"], @"should not happen");
    DIMCommonMessenger *messenger = [self messenger];
    
    // NOTICE: there are too many members in this group
    //         if we still hide the group ID, the cost will be very high.
    //  so,
    //      here I suggest to expose 'group' on this message's envelope
    //      to use a user-to-group password to encrypt the message content,
    //      and the actual receiver can get the decrypt key
    //      with the accurate direction: (sender -> group)
    [iMsg setString:gid forKey:@"group"];
    
    id<MKMID> sender = [iMsg sender];
    
    //
    //  0. pack message
    //
    id<DKDReliableMessage> rMsg = [self.packer encryptAndSignMessage:iMsg];
    if (!rMsg) {
        NSAssert(false, @"failed to encrypt & sign message: %@ => %@", sender, gid);
        return nil;
    }
    
    //
    //  1. split messages
    //
    NSArray<id<DKDReliableMessage>> *messages;
    messages = [self.packer splitReliableMessage:rMsg members:allMembers];
    id<MKMID> receiver;
    BOOL ok;
    for (id<DKDReliableMessage> msg in messages) {
        receiver = [msg receiver];
        if ([sender isEqual:receiver]) {
            NSAssert(false, @"cycled message: %@ => %@, %@", sender, receiver, gid);
            continue;
        }
        //
        //  2. send message
        //
        ok = [messenger sendReliableMessage:rMsg priority:prior];
        NSAssert(ok, @"failed to send message: %@ => %@, %@", sender, receiver, gid);
    }
    
    return rMsg;
}

/**
 *  Split and send (encrypt + sign) group messages to all members one by one
 */
- (NSInteger)_splitAndSendMessage:(id<DKDInstantMessage>)iMsg
                          members:(NSArray<id<MKMID>> *)allMembers
                            group:(id<MKMID>)gid
                         priority:(NSInteger)prior {
    NSAssert([gid isGroup], @"group ID error: %@", gid);
    NSAssert(![iMsg objectForKey:@"group"], @"should not happen");
    DIMCommonMessenger *messenger = [self messenger];
    
    // NOTICE: this is a tiny group
    //         I suggest NOT to expose the group ID to maximize its privacy,
    //         the cost is we cannot use a user-to-group password here;
    //         So the other members can only treat it as a personal message
    //         and use the user-to-user symmetric key to decrypt content,
    //         they can get the group ID after decrypted.
    
    id<MKMID> sender = [iMsg sender];
    NSUInteger success = 0;
    
    //
    //  1. split messages
    //
    NSArray<id<DKDInstantMessage>> *messages;
    messages = [self.packer splitInstantMessage:iMsg members:allMembers];
    id<MKMID> receiver;
    id<DKDReliableMessage> rMsg;
    for (id<DKDInstantMessage> msg in messages) {
        receiver = [msg receiver];
        if ([sender isEqual:receiver]) {
            NSAssert(false, @"cycled message: %@ => %@, %@", sender, receiver, gid);
            continue;
        }
        //
        //  2. send message
        //
        rMsg = [messenger sendInstantMessage:msg priority:prior];
        if (!rMsg) {
            NSLog(@"failed to send message: %@ => %@, %@", sender, receiver, gid);
            continue;
        }
        success += 1;
    }
    
    // done!
    return success;
}

@end
