//
//  DIMTransceiver.m
//  DIM
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMUser.h"
#import "DIMContact.h"
#import "DIMGroup.h"

#import "DIMInstantMessage.h"

#import "DIMTransceiver.h"

@implementation DIMTransceiver

- (DIMCertifiedMessage *)certifiedMessageWithContent:(const DIMMessageContent *)content sender:(const MKMID *)sender receiver:(const MKMID *)receiver {
    DIMEnvelope *env;
    env = [[DIMEnvelope alloc] initWithSender:sender receiver:receiver];
    return [self certifiedMessageWithContent:content envelope:env];
}

- (DIMCertifiedMessage *)certifiedMessageWithContent:(const DIMMessageContent *)content envelope:(const DIMEnvelope *)env {
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:content envelope:env];
    return [self certifiedMessageWithInstantMessage:iMsg];
}

- (DIMCertifiedMessage *)certifiedMessageWithInstantMessage:(const DIMInstantMessage *)message {
    const MKMID *ID;
    const MKMMeta *meta;
    const MKMHistory *history;
    
    MKMEntityManager *em = [MKMEntityManager sharedManager];
    MKMAccountHistoryDelegate *acctDelegate;
    acctDelegate = [[MKMAccountHistoryDelegate alloc] init];
    MKMGroupHistoryDelegate *grpDelegate;
    grpDelegate = [[MKMGroupHistoryDelegate alloc] init];
    
    // envelope
    const DIMInstantMessage *iMsg = message;
    const DIMEnvelope *env = iMsg.envelope;
    
    // 1. encrypt to secure message
    DIMSecureMessage *sMsg = nil;
    
    // receiver
    DIMContact *contact;
    DIMGroup *group;
    ID = env.receiver;
    meta = [em metaWithID:ID];
    history = [em historyWithID:ID];
    if (ID.address.network == MKMNetwork_Main) {
        // receiver is a contact
        contact = [[DIMContact alloc] initWithID:ID meta:meta];
        contact.historyDelegate = acctDelegate;
        [contact runHistory:history];
        if (contact.status != MKMAccountStatusRegistered) {
            NSLog(@"contact.status error");
            return nil;
        }
        // encrypt by contact
        sMsg = [contact encryptMessage:iMsg];
    } else if (ID.address.network == MKMNetwork_Group) {
        // receiver is a group
        group = [[DIMGroup alloc] initWithID:ID meta:meta];
        group.historyDelegate = grpDelegate;
        [group runHistory:history];
        if (group.members.count == 0) {
            NSLog(@"group.members error");
            return nil;
        }
        // encrypt by group
        sMsg = [group encryptMessage:iMsg];
    }
    
    // 2. sign to certified message
    DIMCertifiedMessage *cMsg = nil;
    
    // sender
    DIMUser *sender;
    ID = env.receiver;
    meta = [em metaWithID:ID];
    history = [em historyWithID:ID];
    if (ID.address.network == MKMNetwork_Main) {
        sender = [[DIMUser alloc] initWithID:ID meta:meta];;
        sender.historyDelegate = acctDelegate;
        [sender runHistory:history];
        if (sender.status != MKMAccountStatusRegistered) {
            NSLog(@"sender.status error");
            return nil;
        }
        // sign by sender
        cMsg = [sender signMessage:sMsg];;
    }
    
    return cMsg;
}

- (DIMMessageContent *)contentFromCertifiedMessage:(const DIMCertifiedMessage *)message {
    const DIMInstantMessage *iMsg;
    iMsg = [self instantMessageFromCertifiedMessage:message];
    DIMMessageContent *content = [iMsg.content copy];
    return content;
}

- (DIMInstantMessage *)instantMessageFromCertifiedMessage:(const DIMCertifiedMessage *)message {
    const MKMID *ID;
    const MKMMeta *meta;
    const MKMHistory *history;
    
    MKMEntityManager *em = [MKMEntityManager sharedManager];
    MKMAccountHistoryDelegate *acctDelegate;
    acctDelegate = [[MKMAccountHistoryDelegate alloc] init];
    
    const DIMEnvelope *env = message.envelope;
    
    // 1. verify to secure message
    DIMSecureMessage *sMsg = nil;
    
    // sender
    DIMContact *contact;
    ID = env.sender;
    meta = [em metaWithID:ID];
    history = [em historyWithID:ID];
    if (ID.address.network == MKMNetwork_Main) {
        contact = [[DIMContact alloc] initWithID:ID meta:meta];
        contact.historyDelegate = acctDelegate;
        [contact runHistory:history];
        if (contact.status != MKMAccountStatusRegistered) {
            NSLog(@"contact.status error");
            return nil;
        }
        sMsg = [contact verifyMessage:message];
    }
    
    // 2. decrypt to instant message
    DIMInstantMessage *iMsg = nil;
    
    // receiver
    DIMUser *user;
    ID = env.receiver;
    meta = [em metaWithID:ID];
    history = [em historyWithID:ID];
    if (ID.address.network == MKMNetwork_Main) {
        user = [[DIMUser alloc] initWithID:ID meta:meta];
        user.historyDelegate = acctDelegate;
        [user runHistory:history];
        if (user.status != MKMAccountStatusRegistered) {
            NSLog(@"contact.status error");
            return nil;
        }
        iMsg = [user decryptMessage:sMsg];
    }
    
    return iMsg;
}

@end
