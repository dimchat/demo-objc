//
//  MKMUser+Message.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DIMInstantMessage.h"
#import "DIMSecureMessage.h"
#import "DIMCertifiedMessage.h"
#import "DIMEnvelope.h"
#import "DIMMessageContent.h"

#import "MKMAccount+Message.h"
#import "MKMGroup+Message.h"

#import "DIMKeyStore.h"

#import "MKMUser+Message.h"

@implementation MKMUser (Message)

- (DIMInstantMessage *)decryptMessage:(const DIMSecureMessage *)msg {
    NSAssert([msg.envelope.receiver isEqual:_ID], @"recipient error");
    
    // 1. use symmetric key to decrypt the content
    MKMSymmetricKey *scKey = [self keyForDecrpytMessage:msg];
    NSData *data = [scKey decrypt:msg.data];
    NSAssert(data, @"decrypt content failed");
    
    // 2. JsON
    NSString *json = [data UTF8String];
    DIMMessageContent *content;
    content = [[DIMMessageContent alloc] initWithJSONString:json];
    
    // 3. create instant message
    return [[DIMInstantMessage alloc] initWithContent:content
                                             envelope:msg.envelope];
}

- (DIMCertifiedMessage *)signMessage:(const DIMSecureMessage *)msg {
    NSAssert([msg.envelope.sender isEqual:_ID], @"sender error");
    NSAssert(msg.data, @"content data cannot be empty");
    
    // 1. use the user's private key to sign the content
    NSData *CT = [self.privateKey sign:msg.data];
    
    // 2. create certified message
    DIMCertifiedMessage *cMsg = nil;
    if (MKMNetwork_IsPerson(msg.envelope.receiver.type)) {
        // Personal Message
        cMsg = [[DIMCertifiedMessage alloc] initWithData:msg.data
                                               signature:CT
                                            encryptedKey:msg.encryptedKey
                                                envelope:msg.envelope];
    } else if (MKMNetwork_IsGroup(msg.envelope.receiver.type)) {
        // Group Message
        cMsg = [[DIMCertifiedMessage alloc] initWithData:msg.data
                                               signature:CT
                                           encryptedKeys:msg.encryptedKeys
                                                envelope:msg.envelope];
    } else {
        NSAssert(false, @"error");
    }
    return cMsg;
}

#pragma mark - Passphrase

- (MKMSymmetricKey *)keyForDecrpytMessage:(const DIMSecureMessage *)msg {
    MKMSymmetricKey *scKey = nil;
    NSData *PW = nil;
    
    DIMKeyStore *store = [DIMKeyStore sharedInstance];
    DIMEnvelope *env = msg.envelope;
    MKMID *sender = env.sender;
    MKMID *receiver = env.receiver;
    
    if (MKMNetwork_IsPerson(receiver.type)) {
        NSAssert([receiver isEqual:_ID], @"receiver error: %@", receiver);
        // get passphrase in personal message
        PW = msg.encryptedKey;
        if (!PW) {
            // get passphrase from contact
            scKey = [store cipherKeyFromAccount:sender];
        }
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        // get passphrase in group message
        PW = [msg.encryptedKeys encryptedKeyForID:_ID];
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
