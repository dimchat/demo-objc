//
//  MKMUser+Message.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DKDInstantMessage.h"
#import "DKDSecureMessage.h"
#import "DKDReliableMessage.h"
#import "DKDEnvelope.h"
#import "DKDMessageContent.h"

#import "MKMAccount+Message.h"
#import "MKMGroup+Message.h"

#import "DKDKeyStore.h"

#import "MKMUser+Message.h"

@implementation MKMUser (Message)

- (DKDInstantMessage *)decryptMessage:(const DKDSecureMessage *)sMsg {
    NSAssert([sMsg.envelope.receiver isEqual:_ID], @"recipient error");
    
    // 1. use symmetric key to decrypt the content
    MKMSymmetricKey *scKey = [self keyForDecrpytMessage:sMsg];
    NSData *data = [scKey decrypt:sMsg.data];
    NSAssert(data, @"decrypt content failed");
    
    // 2. JsON
    NSString *json = [data UTF8String];
    DKDMessageContent *content;
    content = [[DKDMessageContent alloc] initWithJSONString:json];
    
    // 3. create instant message
    return [[DKDInstantMessage alloc] initWithContent:content
                                             envelope:sMsg.envelope];
}

- (DKDReliableMessage *)signMessage:(const DKDSecureMessage *)sMsg {
    NSAssert([sMsg.envelope.sender isEqual:_ID], @"sender error");
    NSAssert(sMsg.data, @"content data cannot be empty");
    
    // 1. use the user's private key to sign the content
    NSData *CT = [self.privateKey sign:sMsg.data];
    
    // 2. create reliable message
    DKDReliableMessage *rMsg = nil;
    if (MKMNetwork_IsPerson(sMsg.envelope.receiver.type)) {
        // Personal Message
        rMsg = [[DKDReliableMessage alloc] initWithData:sMsg.data
                                              signature:CT
                                           encryptedKey:sMsg.encryptedKey
                                               envelope:sMsg.envelope];
    } else if (MKMNetwork_IsGroup(sMsg.envelope.receiver.type)) {
        // Group Message
        rMsg = [[DKDReliableMessage alloc] initWithData:sMsg.data
                                              signature:CT
                                          encryptedKeys:sMsg.encryptedKeys
                                               envelope:sMsg.envelope];
    } else {
        NSAssert(false, @"error");
    }
    return rMsg;
}

#pragma mark - Passphrase

- (MKMSymmetricKey *)keyForDecrpytMessage:(const DKDSecureMessage *)sMsg {
    MKMSymmetricKey *scKey = nil;
    NSData *PW = nil;
    
    DKDKeyStore *store = [DKDKeyStore sharedInstance];
    MKMID *sender = sMsg.envelope.sender;
    MKMID *receiver = sMsg.envelope.receiver;
    
    if (MKMNetwork_IsPerson(receiver.type)) {
        NSAssert([receiver isEqual:_ID], @"receiver error: %@", receiver);
        // get passphrase in personal message
        PW = sMsg.encryptedKey;
        if (!PW) {
            // get passphrase from contact
            scKey = [store cipherKeyFromAccount:sender];
        }
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        // get passphrase in group message
        PW = [sMsg.encryptedKeys encryptedKeyForID:_ID];
        if (!PW) {
            // get passphrase from group.member
            scKey = [store cipherKeyFromMember:sender inGroup:receiver];
        }
    } else {
        NSAssert(false, @"error");
    }
    
    if (PW) {
        PW = [self.privateKey decrypt:PW];
        NSAssert(PW, @"decrypt key failed");
        scKey = [[MKMSymmetricKey alloc] initWithJSONString:[PW UTF8String]];
    }
    
    NSAssert(scKey, @"key not found");
    return scKey;
}

@end
