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

- (DIMInstantMessage *)verifyAndDecryptMessage:(DIMReliableMessage *)rMsg {
    // 0. [Meta Protocol] check meta in first contact message
    DIMID *sender = [_barrack IDWithString:rMsg.envelope.sender];
    DIMMeta *meta = [_barrack metaForID:sender];
    if (!meta) {
        // first contact, try meta in message package
        meta = MKMMetaFromDictionary(rMsg.meta);
        if (!meta) {
            // TODO: query meta for sender from DIM network
            NSAssert(false, @"failed to get meta for sender: %@", sender);
            return nil;
        }
        NSAssert([meta matchID:sender], @"meta not match: %@, %@", sender, meta);
        DIMFacebook *facebook = [DIMFacebook sharedInstance];
        if (![facebook saveMeta:meta forID:sender]) {
            NSAssert(false, @"save meta error: %@, %@", sender, meta);
            return nil;
        }
    }
    
    // 1. verify and decrypt
    DIMInstantMessage *iMsg = [super verifyAndDecryptMessage:rMsg];
    
    // 2. check: top-secret message
    if (iMsg.delegate == nil) {
        iMsg.delegate = self;
    }
    NSAssert(iMsg.content, @"content cannot be empty");
    if (iMsg.content.type == DKDContentType_Forward) {
        // do it again to drop the wrapper,
        // the secret inside the content is the real message
        DIMForwardContent *content = (DIMForwardContent *)iMsg.content;
        rMsg = content.forwardMessage;
        
        DIMInstantMessage *secret = [self verifyAndDecryptMessage:rMsg];
        if (secret) {
            return secret;
        }
        // FIXME: not for you?
    }
    
    return iMsg;
}

@end

@implementation DIMTransceiver (Transform)

- (DIMSymmetricKey *)_passwordFrom:(DIMID *)sender to:(DIMID *)receiver {
    // 1. get old key from store
    DIMSymmetricKey *reusedKey;
    reusedKey = [_keyCache cipherKeyFrom:sender to:receiver];
    // 2. get new key from delegate
    DIMSymmetricKey *newKey;
    newKey = [_keyCache reuseCipherKey:reusedKey from:sender to:receiver];
    if (!newKey) {
        if (!reusedKey) {
            // 3. create a new key
            newKey = MKMSymmetricKeyWithAlgorithm(SCAlgorithmAES);
        } else {
            newKey = reusedKey;
        }
    }
    // 4. update new key into the key store
    if (![newKey isEqual:reusedKey]) {
        [_keyCache cacheCipherKey:newKey from:sender to:receiver];
    }
    return newKey;
}

- (nullable DIMReliableMessage *)encryptAndSignMessage:(DIMInstantMessage *)iMsg {
    DIMID *sender = [_barrack IDWithString:iMsg.envelope.sender];
    DIMID *receiver = [_barrack IDWithString:iMsg.envelope.receiver];
    // if 'group' exists and the 'receiver' is a group ID,
    // they must be equal
    DIMGroup *group = nil;
    if (MKMNetwork_IsGroup(receiver.type)) {
        group = [_barrack groupWithID:receiver];
    } else {
        NSString *gid = iMsg.group;
        if (gid) {
            group = [_barrack groupWithID:[_barrack IDWithString:gid]];
        }
    }
    
    // 1. encrypt 'content' to 'data' for receiver
    if (iMsg.delegate == nil) {
        iMsg.delegate = self;
    }
    NSAssert(iMsg.content, @"content cannot be empty");
    DIMSecureMessage *sMsg;
    if (!group) {
        // personal message
        DIMSymmetricKey *password = [self _passwordFrom:sender to:receiver];
        sMsg = [iMsg encryptWithKey:password];
    } else {
        // group message
        DIMSymmetricKey *password = [self _passwordFrom:sender to:group.ID];
        sMsg = [iMsg encryptWithKey:password forMembers:group.members];
    }
    
    // 2. sign 'data' by sender
    if (sMsg.delegate == nil) {
        sMsg.delegate = self;
    }
    NSAssert(sMsg.data, @"data cannot be empty");
    return [sMsg sign];
}

- (nullable DIMInstantMessage *)verifyAndDecryptMessage:(DIMReliableMessage *)rMsg {
    /*
     // [Meta Protocol] check meta in first contact message
     DIMID *sender = [_barrack IDWithString:rMsg.envelope.sender];
     DIMMeta *meta = [_barrack metaForID:sender];
     if (!meta) {
     // first contact, try meta in message package
     meta = MKMMetaFromDictionary(rMsg.meta);
     if (!meta) {
     // TODO: query meta for sender from DIM network
     NSAssert(false, @"failed to get meta for sender: %@", sender);
     return nil;
     }
     NSAssert([meta matchID:sender], @"meta not match: %@, %@", sender, meta);
     if (![_barrack saveMeta:meta forID:sender]) {
     NSAssert(false, @"save meta error: %@, %@", sender, meta);
     return nil;
     }
     }
     */
    // 1. verify 'data' with 'signature'
    if (rMsg.delegate == nil) {
        rMsg.delegate = self;
    }
    NSAssert(rMsg.signature, @"signature cannot be empty");
    DIMSecureMessage *sMsg = [rMsg verify];
    
    // 2. decrypt 'data' to 'content'
    if (sMsg.delegate == nil) {
        sMsg.delegate = self;
    }
    NSAssert(sMsg.data, @"data cannot be empty");
    DIMInstantMessage *iMsg = [sMsg decrypt];
    /*
     // 3. check: top-secret message
     if (iMsg.delegate == nil) {
     iMsg.delegate = self;
     }
     NSAssert(iMsg.content, @"content cannot be empty");
     if (iMsg.content.type == DKDContentType_Forward) {
     // do it again to drop the wrapper,
     // the secret inside the content is the real message
     DIMForwardContent *content = (DIMForwardContent *)iMsg.content;
     rMsg = content.forwardMessage;
     
     DIMInstantMessage *secret = [self verifyAndDecryptMessage:rMsg];
     if (secret) {
     return secret;
     }
     // FIXME: not for you?
     }
     */
    // OK
    return iMsg;
}

@end

@implementation DIMTransceiver (Send)

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
                   callback:(DIMTransceiverCallback)callback {
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
