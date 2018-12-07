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
#import "DIMReliableMessage.h"
#import "DIMEnvelope.h"
#import "DIMMessageContent.h"

#import "MKMAccount+Message.h"
#import "MKMGroup+Message.h"

#import "DIMKeyStore.h"

#import "MKMUser+Message.h"

@implementation MKMUser (Message)

- (DIMInstantMessage *)decryptMessage:(const DIMSecureMessage *)sMsg {
    NSAssert([sMsg.envelope.receiver isEqual:_ID], @"recipient error");
    
    // 1. use symmetric key to decrypt the content
    MKMSymmetricKey *scKey = [self keyForDecrpytMessage:sMsg];
    NSData *data = [scKey decrypt:sMsg.data];
    NSAssert(data, @"decrypt content failed");
    
    // 2. JsON
    NSString *json = [data UTF8String];
    DIMMessageContent *content;
    content = [[DIMMessageContent alloc] initWithJSONString:json];
    
    // 3. create instant message
    return [[DIMInstantMessage alloc] initWithContent:content
                                             envelope:sMsg.envelope];
}

- (DIMReliableMessage *)signMessage:(const DIMSecureMessage *)sMsg {
    NSAssert([sMsg.envelope.sender isEqual:_ID], @"sender error");
    NSAssert(sMsg.data, @"content data cannot be empty");
    
    // 1. use the user's private key to sign the content
    NSData *CT = [self.privateKey sign:sMsg.data];
    
    // 2. create reliable message
    DIMReliableMessage *rMsg = nil;
    if (MKMNetwork_IsPerson(sMsg.envelope.receiver.type)) {
        // Personal Message
        rMsg = [[DIMReliableMessage alloc] initWithData:sMsg.data
                                              signature:CT
                                           encryptedKey:sMsg.encryptedKey
                                               envelope:sMsg.envelope];
    } else if (MKMNetwork_IsGroup(sMsg.envelope.receiver.type)) {
        // Group Message
        rMsg = [[DIMReliableMessage alloc] initWithData:sMsg.data
                                              signature:CT
                                          encryptedKeys:sMsg.encryptedKeys
                                               envelope:sMsg.envelope];
    } else {
        NSAssert(false, @"error");
    }
    return rMsg;
}

#pragma mark - Passphrase

- (MKMSymmetricKey *)keyForDecrpytMessage:(const DIMSecureMessage *)sMsg {
    MKMSymmetricKey *scKey = nil;
    NSData *PW = nil;
    
    DIMKeyStore *store = [DIMKeyStore sharedInstance];
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
