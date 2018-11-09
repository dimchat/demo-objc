//
//  DIMTransceiver.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMAccount+Message.h"
#import "MKMUser+Message.h"
#import "MKMGroup+Message.h"

#import "DIMEnvelope.h"
#import "DIMMessageContent.h"
#import "DIMMessageContent+Secret.h"

#import "DIMInstantMessage.h"
#import "DIMCertifiedMessage.h"

#import "DIMTransceiver.h"

@implementation DIMTransceiver

SingletonImplementations(DIMTransceiver, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (DIMCertifiedMessage *)encryptAndSignContent:(const DIMMessageContent *)content
                                        sender:(const MKMID *)sender
                                      receiver:(const MKMID *)receiver {
    NSAssert(MKMNetwork_IsPerson(sender.type), @"sender error");
    NSAssert(receiver.isValid, @"receiver error");
    
    // 1. make envelope
    DIMEnvelope *env;
    env = [[DIMEnvelope alloc] initWithSender:sender
                                     receiver:receiver
                                         time:nil];
    
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
    
    // 3. check: top-secret message
    if (iMsg.content.type == DIMMessageType_Forward) {
        // do it again to drop the wrapper,
        // the secret inside the content is the real message
        cMsg = iMsg.content.forwardMessage;
        return [self verifyAndDecryptMessage:cMsg];
    }
    
    // OK
    NSAssert(iMsg.content, @"content cannot be empty");
    return iMsg;
}

#pragma mark -

- (DIMSecureMessage *)encryptMessage:(const DIMInstantMessage *)iMsg {
    DIMSecureMessage *sMsg = nil;
    
    // encrypt to secure message by receiver
    MKMID *receiver = iMsg.envelope.receiver;
    if (MKMNetwork_IsPerson(receiver.type)) {
        // receiver is a contact
        MKMContact *contact = MKMContactWithID(receiver);
        sMsg = [contact encryptMessage:iMsg];
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        // receiver is a group
        MKMGroup *group = MKMGroupWithID(receiver);
        sMsg = [group encryptMessage:iMsg];
    }
    
    NSAssert(sMsg.data, @"encrypt failed");
    return sMsg;
}

- (DIMInstantMessage *)decryptMessage:(const DIMSecureMessage *)sMsg {
    DIMInstantMessage *iMsg = nil;
    
    // decrypt to instant message by receiver
    MKMID *receiver = sMsg.envelope.receiver;
    if (MKMNetwork_IsPerson(receiver.type)) {
        MKMUser *user = MKMUserWithID(receiver);
        iMsg = [user decryptMessage:sMsg];
    }
    
    NSAssert(iMsg.content, @"decrypt failed");
    return iMsg;
}

- (DIMCertifiedMessage *)signMessage:(const DIMSecureMessage *)sMsg {
    DIMCertifiedMessage *cMsg = nil;
    
    // sign to certified message by sender
    MKMID *sender = sMsg.envelope.sender;
    if (MKMNetwork_IsPerson(sender.type)) {
        MKMUser *user = MKMUserWithID(sender);
        cMsg = [user signMessage:sMsg];;
    }
    
    NSAssert(cMsg.signature, @"sign failed");
    return cMsg;
}

- (DIMSecureMessage *)verifyMessage:(const DIMCertifiedMessage *)cMsg {
    DIMSecureMessage *sMsg = nil;
    
    // verify to secure message by sender
    MKMID *sender = cMsg.envelope.sender;
    if (MKMNetwork_IsPerson(sender.type)) {
        MKMContact *contact = MKMContactWithID(sender);
        sMsg = [contact verifyMessage:cMsg];
    }
    
    NSAssert(sMsg.data, @"verify failed");
    return sMsg;
}

@end
