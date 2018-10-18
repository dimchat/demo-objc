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

- (DIMCertifiedMessage *)encryptAndSignContent:(const DIMMessageContent *)content
                                        sender:(const MKMID *)sender
                                      receiver:(const MKMID *)receiver {
    NSAssert(sender.address.network == MKMNetwork_Main, @"sender error");
    NSAssert(receiver.isValid, @"receiver error");
    
    // 1. make envelope
    DIMEnvelope *env;
    env = [[DIMEnvelope alloc] initWithSender:sender receiver:receiver];
    
    // 2. make instant message
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:content envelope:env];
    
    // 3. encrypt to secure message
    DIMSecureMessage *sMsg;
    sMsg = [self encryptMessage:iMsg];
    
    // 4. sign to certified message
    DIMCertifiedMessage *cMsg;
    cMsg = [self signMessage:sMsg];
    
    // OK
    NSAssert(cMsg.signature, @"signature cannot be empty");
    return cMsg;
}

- (DIMInstantMessage *)verifyAndDecryptMessage:(const DIMCertifiedMessage *)cMsg {
    NSAssert(cMsg.signature, @"signature cannot be empty");
    
    // 1. verify to secure message
    DIMSecureMessage *sMsg;
    sMsg = [self verifyMessage:cMsg];
    
    // 2. decrypt to instant message
    DIMInstantMessage *iMsg;
    iMsg = [self decryptMessage:sMsg];
    
    // OK
    NSAssert(iMsg.content, @"content cannot be empty");
    return iMsg;
}

#pragma mark -

- (DIMSecureMessage *)encryptMessage:(const DIMInstantMessage *)iMsg {
    DIMSecureMessage *sMsg = nil;
    
    // encrypt to secure message by receiver
    MKMID *receiver = iMsg.envelope.receiver;
    if (receiver.address.network == MKMNetwork_Main) {
        // receiver is a contact
        DIMContact *contact = [DIMContact contactWithID:receiver];
        sMsg = [contact encryptMessage:iMsg];
    } else if (receiver.address.network == MKMNetwork_Group) {
        // receiver is a group
        DIMGroup *group = [DIMGroup groupWithID:receiver];
        sMsg = [group encryptMessage:iMsg];
    }
    
    NSAssert(sMsg.content, @"encrypt failed");
    return sMsg;
}

- (DIMInstantMessage *)decryptMessage:(const DIMSecureMessage *)sMsg {
    DIMInstantMessage *iMsg = nil;
    
    // decrypt to instant message by receiver
    MKMID *receiver = sMsg.envelope.receiver;
    if (receiver.address.network == MKMNetwork_Main) {
        DIMUser *user = [DIMUser userWithID:receiver];
        iMsg = [user decryptMessage:sMsg];
    }
    
    NSAssert(iMsg.content, @"decrypt failed");
    return iMsg;
}

- (DIMCertifiedMessage *)signMessage:(const DIMSecureMessage *)sMsg {
    DIMCertifiedMessage *cMsg = nil;
    
    // sign to certified message by sender
    MKMID *sender = sMsg.envelope.sender;
    if (sender.address.network == MKMNetwork_Main) {
        DIMUser *user = [DIMUser userWithID:sender];
        cMsg = [user signMessage:sMsg];;
    }
    
    NSAssert(cMsg.signature, @"sign failed");
    return cMsg;
}

- (DIMSecureMessage *)verifyMessage:(const DIMCertifiedMessage *)cMsg {
    DIMSecureMessage *sMsg = nil;
    
    // verify to secure message by sender
    MKMID *sender = cMsg.envelope.sender;
    if (sender.address.network == MKMNetwork_Main) {
        DIMContact *contact = [DIMContact contactWithID:sender];
        sMsg = [contact verifyMessage:cMsg];
    }
    
    NSAssert(sMsg.content, @"verify failed");
    return sMsg;
}

@end
