//
//  DKDTransceiver.m
//  DaoKeDaoe
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSObject+JsON.h"

#import "MKMAccount+Message.h"
#import "MKMUser+Message.h"
#import "MKMGroup+Message.h"

#import "DKDEnvelope.h"
#import "DKDMessageContent.h"
#import "DKDMessageContent+Forward.h"

#import "DKDMessage.h"
#import "DKDInstantMessage.h"
#import "DKDSecureMessage.h"
#import "DKDReliableMessage.h"

#import "DKDTransceiver.h"

@implementation DKDTransceiver

SingletonImplementations(DKDTransceiver, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (BOOL)sendMessageContent:(const DKDMessageContent *)content
                      from:(const MKMID *)sender
                        to:(const MKMID *)receiver
                      time:(nullable const NSDate *)time
                  callback:(nullable DKDTransceiverCallback)callback {
    // make instant message
    DKDInstantMessage *iMsg;
    iMsg = [[DKDInstantMessage alloc] initWithContent:content
                                               sender:sender
                                             receiver:receiver
                                                 time:time];
    
    return [self sendMessage:iMsg callback:callback];
}

- (BOOL)sendMessage:(const DKDInstantMessage *)iMsg
           callback:(nullable DKDTransceiverCallback)callback {
    DKDReliableMessage *rMsg = [self encryptAndSignMessage:iMsg];
    NSData *data = [rMsg jsonData];
    if (data) {
        NSAssert(_delegate, @"transceiver delegate not set");
        return [_delegate sendPackage:data
                    completionHandler:^(const NSError * _Nullable error) {
                        assert(!error);
                        !callback ?: callback(rMsg, error);
                    }];
    } else {
        NSAssert(false, @"message data error: %@", iMsg);
        return NO;
    }
}

- (DKDInstantMessage *)messageFromReceivedPackage:(const NSData *)data {
    NSString *json = [data UTF8String];
    DKDReliableMessage *rMsg;
    rMsg = [[DKDReliableMessage alloc] initWithJSONString:json];
    return [self verifyAndDecryptMessage:rMsg];
}

#pragma mark -

- (DKDReliableMessage *)encryptAndSignContent:(const DKDMessageContent *)content
                                       sender:(const MKMID *)sender
                                     receiver:(const MKMID *)receiver
                                         time:(nullable const NSDate *)time {
    NSAssert(MKMNetwork_IsPerson(sender.type), @"sender error");
    NSAssert(receiver.isValid, @"receiver error");
    
    // make instant message
    DKDInstantMessage *iMsg;
    iMsg = [[DKDInstantMessage alloc] initWithContent:content
                                               sender:sender
                                             receiver:receiver
                                                 time:time];
    
    // let another selector to do the continue jobs
    return [self encryptAndSignMessage:iMsg];
}

- (DKDReliableMessage *)encryptAndSignMessage:(const DKDInstantMessage *)iMsg {
    // 1. encrypt to secure message
    DKDSecureMessage *sMsg;
    sMsg = [self encryptMessage:iMsg];
    
    // 2. sign to reliable message
    DKDReliableMessage *rMsg;
    rMsg = [self signMessage:sMsg];
    
    // OK
    NSAssert(rMsg.signature, @"signature cannot be empty");
    return rMsg;
}

- (DKDInstantMessage *)verifyAndDecryptMessage:(const DKDReliableMessage *)rMsg {
    NSAssert(rMsg.signature, @"signature cannot be empty");
    
    // 1. verify to secure message
    DKDSecureMessage *sMsg;
    sMsg = [self verifyMessage:rMsg];
    
    // 2. decrypt to instant message
    DKDInstantMessage *iMsg;
    iMsg = [self decryptMessage:sMsg];
    
    // 3. check: top-secret message
    if (iMsg.content.type == DKDMessageType_Forward) {
        // do it again to drop the wrapper,
        // the secret inside the content is the real message
        rMsg = iMsg.content.forwardMessage;
        return [self verifyAndDecryptMessage:rMsg];
    }
    
    // OK
    NSAssert(iMsg.content, @"content cannot be empty");
    return iMsg;
}

#pragma mark -

- (DKDSecureMessage *)encryptMessage:(const DKDInstantMessage *)iMsg {
    DKDSecureMessage *sMsg = nil;
    
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

- (DKDInstantMessage *)decryptMessage:(const DKDSecureMessage *)sMsg {
    DKDInstantMessage *iMsg = nil;
    
    // decrypt to instant message by receiver
    MKMID *receiver = sMsg.envelope.receiver;
    if (MKMNetwork_IsPerson(receiver.type)) {
        MKMUser *user = MKMUserWithID(receiver);
        iMsg = [user decryptMessage:sMsg];
    }
    
    NSAssert(iMsg.content, @"decrypt failed");
    return iMsg;
}

- (DKDReliableMessage *)signMessage:(const DKDSecureMessage *)sMsg {
    DKDReliableMessage *rMsg = nil;
    
    // sign to reliable message by sender
    MKMID *sender = sMsg.envelope.sender;
    if (MKMNetwork_IsPerson(sender.type)) {
        MKMUser *user = MKMUserWithID(sender);
        rMsg = [user signMessage:sMsg];;
    }
    
    NSAssert(rMsg.signature, @"sign failed");
    return rMsg;
}

- (DKDSecureMessage *)verifyMessage:(const DKDReliableMessage *)rMsg {
    DKDSecureMessage *sMsg = nil;
    
    // verify to secure message by sender
    MKMID *sender = rMsg.envelope.sender;
    if (MKMNetwork_IsPerson(sender.type)) {
        MKMContact *contact = MKMContactWithID(sender);
        sMsg = [contact verifyMessage:rMsg];
    }
    
    NSAssert(sMsg.data, @"verify failed");
    return sMsg;
}

@end
