//
//  DIMMessenger.m
//  DIMClient
//
//  Created by Albert Moky on 2019/8/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "NSObject+Singleton.h"

#import "DIMFacebook+Storage.h"
#import "DIMKeyStore.h"

#import "DIMMessenger.h"

@implementation DIMMessenger

SingletonImplementations(DIMMessenger, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        // delegates
        _barrack = [DIMFacebook sharedInstance];
        _keyCache = [DIMKeyStore sharedInstance];
    }
    return self;
}

- (nullable DIMSecureMessage *)verifyMessage:(DIMReliableMessage *)rMsg {
    
    // [Meta Protocol] check meta in first contact message
    DIMID *sender = [_barrack IDWithString:rMsg.envelope.sender];
    DIMMeta *meta = [_barrack metaForID:sender];
    if (!meta) {
        // first contact, try meta in message package
        meta = MKMMetaFromDictionary(rMsg.meta);
        if (!meta) {
            // TODO: query meta for sender from DIM network
            //       (do it by application)
            return nil;
        } else if ([meta matchID:sender]) {
            DIMFacebook *facebook = [DIMFacebook sharedInstance];
            if (![facebook saveMeta:meta forID:sender]) {
                NSAssert(false, @"save meta error: %@, %@", sender, meta);
                return nil;
            }
        } else {
            NSAssert(false, @"meta not match: %@, %@", sender, meta);
            return nil;
        }
    }
    
    return [super verifyMessage:rMsg];
}

- (nullable DIMInstantMessage *)decryptMessage:(DIMSecureMessage *)sMsg {
    DIMInstantMessage *iMsg = [super decryptMessage:sMsg];
    
    // check: top-secret message
    NSAssert(iMsg.content, @"content cannot be empty");
    if (iMsg.content.type == DKDContentType_Forward) {
        // do it again to drop the wrapper,
        // the secret inside the content is the real message
        DIMForwardContent *content = (DIMForwardContent *)iMsg.content;
        DIMReliableMessage *rMsg = content.forwardMessage;
        
        DIMInstantMessage *secret = [self verifyAndDecryptMessage:rMsg];
        if (secret) {
            return secret;
        }
        // FIXME: not for you?
    }
    
    return iMsg;
}

@end

@implementation DIMMessenger (Convenience)


- (nullable DIMReliableMessage *)encryptAndSignMessage:(DIMInstantMessage *)iMsg {

    // 1. encrypt 'content' to 'data' for receiver
    DIMSecureMessage *sMsg = [self encryptMessage:iMsg];
    
    // 2. sign 'data' by sender
    DIMReliableMessage *rMsg = [self signMessage:sMsg];
    
    // OK
    return rMsg;
}

- (nullable DIMInstantMessage *)verifyAndDecryptMessage:(DIMReliableMessage *)rMsg {
    
    // 1. verify 'data' with 'signature'
    DIMSecureMessage *sMsg = [self verifyMessage:rMsg];
    
    // 2. check group message
    DIMID *receiver = [_barrack IDWithString:sMsg.envelope.receiver];
    if (MKMNetwork_IsGroup(receiver.type)) {
        // TODO: split it
    }
    
    // 3. decrypt 'data' to 'content'
    DIMInstantMessage *iMsg = [self decryptMessage:sMsg];
    
    // OK
    return iMsg;
}

@end

@implementation DIMMessenger (Send)

- (BOOL)sendInstantMessage:(DIMInstantMessage *)iMsg
                  callback:(nullable DIMTransceiverCallback)callback
               dispersedly:(BOOL)split {
    // transforming
    DIMID *receiver = [_barrack IDWithString:iMsg.envelope.receiver];
    DIMID *groupID = [_barrack IDWithString:iMsg.content.group];
    DIMReliableMessage *rMsg = [self encryptAndSignMessage:iMsg];
    if (!rMsg) {
        NSAssert(false, @"failed to encrypt and sign message: %@", iMsg);
        iMsg.state = DIMMessageState_Error;
        iMsg.error = @"Encryption failed.";
        return NO;
    }
    
    // trying to send out
    BOOL OK = YES;
    if (split && MKMNetwork_IsGroup(receiver.type)) {
        NSAssert([receiver isEqual:groupID], @"group ID error: %@", iMsg);
        DIMGroup *group = [_barrack groupWithID:groupID];
        NSArray *messages = [rMsg splitForMembers:group.members];
        if (messages.count == 0) {
            NSLog(@"failed to split msg, send it to group: %@", receiver);
            OK = [self sendReliableMessage:rMsg callback:callback];
        } else {
            for (rMsg in messages) {
                if ([self sendReliableMessage:rMsg callback:callback]) {
                    //NSLog(@"group message sent to %@", rMsg.envelope.receiver);
                } else {
                    OK = NO;
                }
            }
        }
    } else {
        OK = [self sendReliableMessage:rMsg callback:callback];
    }
    
    // sending status
    if (OK) {
        iMsg.state = DIMMessageState_Sending;
    } else {
        NSLog(@"cannot send message now, put in waiting queue: %@", iMsg);
        iMsg.state = DIMMessageState_Waiting;
    }
    return OK;
}

- (BOOL)sendReliableMessage:(DIMReliableMessage *)rMsg
                   callback:(nullable DIMTransceiverCallback)callback {
    NSData *data = [rMsg jsonData];
    if (data) {
        NSAssert(_delegate, @"transceiver delegate not set");
        return [_delegate sendPackage:data
                    completionHandler:^(NSError * _Nullable error) {
                        !callback ?: callback(rMsg, error);
                    }];
    } else {
        NSAssert(false, @"message data error: %@", rMsg);
        return NO;
    }
}

@end
