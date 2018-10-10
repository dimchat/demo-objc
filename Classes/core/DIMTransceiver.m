//
//  DIMTransceiver.m
//  DIM
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMUser.h"
#import "DIMContact.h"
#import "DIMGroup.h"

#import "DIMEnvelope.h"
#import "DIMMessageContent.h"
#import "DIMInstantMessage.h"
#import "DIMCertifiedMessage.h"

#import "DIMTransceiver.h"

@implementation DIMTransceiver

#pragma mark - prepare message for sending out

- (DIMCertifiedMessage *)certifiedMessageWithContent:(const DIMMessageContent *)content
                                              sender:(const MKMID *)sender
                                            receiver:(const MKMID *)receiver {
    DIMEnvelope *env;
    env = [[DIMEnvelope alloc] initWithSender:sender receiver:receiver];
    return [self certifiedMessageWithContent:content envelope:env];
}

- (DIMCertifiedMessage *)certifiedMessageWithContent:(const DIMMessageContent *)content
                                            envelope:(const DIMEnvelope *)env {
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:content envelope:env];
    return [self certifiedMessageWithInstantMessage:iMsg];
}

- (DIMCertifiedMessage *)certifiedMessageWithInstantMessage:(const DIMInstantMessage *)message {
    // envelope
    const DIMInstantMessage *iMsg = message;
    const DIMEnvelope *env = iMsg.envelope;
    
    // 1. encrypt to secure message by receiver
    DIMSecureMessage *sMsg = nil;
    const MKMID *receiver = env.receiver;
    if (receiver.address.network == MKMNetwork_Main) {
        // receiver is a contact
        DIMContact *contact = [DIMContact contactWithID:receiver];
        sMsg = [contact encryptMessage:iMsg];
    } else if (receiver.address.network == MKMNetwork_Group) {
        // receiver is a group
        DIMGroup *group = [DIMGroup groupWithID:receiver];
        sMsg = [group encryptMessage:iMsg];
    } else {
        NSAssert(false, @"receiver error");
        return nil;
    }
    
    // 2. sign to certified message by sender
    DIMCertifiedMessage *cMsg = nil;
    const MKMID *sender = env.sender;
    if (sender.address.network == MKMNetwork_Main) {
        DIMUser *user = [DIMUser userWithID:sender];
        // sign by sender
        cMsg = [user signMessage:sMsg];;
    } else {
        NSAssert(false, @"sender error");
        return nil;
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
    // envelope
    const DIMCertifiedMessage *cMsg = message;
    const DIMEnvelope *env = cMsg.envelope;
    
    // 1. verify to secure message by sender
    DIMSecureMessage *sMsg = nil;
    const MKMID *sender = env.sender;
    if (sender.address.network == MKMNetwork_Main) {
        DIMContact *contact = [DIMContact contactWithID:sender];
        sMsg = [contact verifyMessage:message];
    } else {
        NSAssert(false, @"sender error");
        return nil;
    }
    
    // 2. decrypt to instant message by receiver
    DIMInstantMessage *iMsg = nil;
    const MKMID *receiver = env.receiver;
    if (receiver.address.network == MKMNetwork_Main) {
        DIMUser *user = [DIMUser userWithID:receiver];
        iMsg = [user decryptMessage:sMsg];
    } else {
        NSAssert(false, @"receiver error");
        return nil;
    }
    
    return iMsg;
}

@end
