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
    DIMEnvelope *env = msg.envelope;
    NSAssert([env.receiver isEqual:_ID], @"recipient error");
    
    // 1. use the user's private key to decrypt the symmetric key
    NSData *PW = msg.encryptedKey;
    NSAssert(PW, @"encrypted key cannot be empty");
    PW = [self.privateKey decrypt:PW];
    
    // 2. use the symmetric key to decrypt the content
    MKMSymmetricKey *scKey = [self keyForDecrpytMessage:msg];
    NSData *data = [scKey decrypt:msg.data];
    NSAssert(data, @"decrypt content failed");
    
    // 3. JsON
    NSString *json = [data UTF8String];
    DIMMessageContent *content;
    content = [[DIMMessageContent alloc] initWithJSONString:json];
    
    // 4. create instant message
    return [[DIMInstantMessage alloc] initWithContent:content
                                             envelope:env];
}

- (DIMCertifiedMessage *)signMessage:(const DIMSecureMessage *)msg {
    DIMEnvelope *env = msg.envelope;
    NSAssert([env.sender isEqual:_ID], @"sender error");
    
    NSData *content = msg.data;
    NSAssert(content, @"content cannot be empty");
    NSData *digest = [content sha256d];
    
    // 1. use the user's private key to sign the content
    NSData *CT = [self.privateKey sign:digest];
    
    // 2. create certified message
    DIMCertifiedMessage *cMsg = nil;
    if (MKMNetwork_IsPerson(env.receiver.type)) {
        // Personal Message
        NSData *key = msg.encryptedKey;
        NSAssert(key, @"encrypted key not found");
        cMsg = [[DIMCertifiedMessage alloc] initWithData:content
                                               signature:CT
                                            encryptedKey:key
                                                envelope:env];
    } else if (MKMNetwork_IsGroup(env.receiver.type)) {
        // Group Message
        DIMEncryptedKeyMap *keys = msg.encryptedKeys;
        NSAssert(keys, @"encrypted keys not found");
        cMsg = [[DIMCertifiedMessage alloc] initWithData:content
                                               signature:CT
                                           encryptedKeys:keys
                                                envelope:env];
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
    }
    
    if (PW) {
        PW = [self.privateKey decrypt:PW];
        NSAssert(PW, @"decrypt key failed");
        scKey = [[MKMSymmetricKey alloc] initWithJSONString:[PW UTF8String]];
    }
    return scKey;
}

@end
