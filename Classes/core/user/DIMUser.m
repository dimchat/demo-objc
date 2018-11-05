//
//  DIMUser.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMInstantMessage.h"
#import "DIMSecureMessage.h"
#import "DIMCertifiedMessage.h"
#import "DIMEnvelope.h"
#import "DIMMessageContent.h"

#import "DIMContact.h"
#import "DIMGroup.h"

#import "DIMBarrack.h"

#import "DIMKeyStore.h"

#import "DIMUser.h"

@implementation DIMUser

- (NSString *)name {
    MKMProfile *profile = DIMProfileForID(_ID);
    NSString *str = profile.name;
    if (str) {
        return str;
    }
    return [super name];
}

- (DIMInstantMessage *)decryptMessage:(const DIMSecureMessage *)msg {
    DIMEnvelope *env = msg.envelope;
    NSAssert([env.receiver isEqual:_ID], @"recipient error");
    
    // 1. use the user's private key to decrypt the symmetric key
    NSData *PW = msg.encryptedKey;
    NSAssert(PW, @"encrypted key cannot be empty");
    PW = [self decrypt:PW];
    
    // 2. use the symmetric key to decrypt the content
    MKMSymmetricKey *scKey = [self cipherKeyForDecrpyt:msg];
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
    
    // 1. use the user's private key to sign the content
    NSData *CT = [self sign:content];
    
    // 2. create certified message
    DIMCertifiedMessage *cMsg = nil;
    if (env.receiver.address.network == MKMNetwork_Main) {
        // Personal Message
        NSData *key = msg.encryptedKey;
        NSAssert(key, @"encrypted key not found");
        cMsg = [[DIMCertifiedMessage alloc] initWithData:content
                                               signature:CT
                                            encryptedKey:key
                                                envelope:env];
    } else if (env.receiver.address.network == MKMNetwork_Group) {
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

#pragma mark - Decrypt/Sign functions for passphrase/signature

- (NSData *)decrypt:(const NSData *)ciphertext {
    MKMPrivateKey *SK = [self privateKey];
    NSAssert(SK, @"private key not found");
    return [SK decrypt:ciphertext];
}

- (NSData *)sign:(const NSData *)plaintext {
    MKMPrivateKey *SK = [self privateKey];
    NSAssert(SK, @"private key not found");
    return [SK sign:plaintext];
}

#pragma mark - Passphrase

- (MKMSymmetricKey *)cipherKeyForDecrpyt:(const DIMSecureMessage *)msg {
    MKMSymmetricKey *scKey = nil;
    NSData *PW = nil;
    
    DIMKeyStore *store = [DIMKeyStore sharedInstance];
    DIMEnvelope *env = msg.envelope;
    MKMID *sender = env.sender;
    MKMID *receiver = env.receiver;
    
    if (receiver.address.network == MKMNetwork_Main) {
        NSAssert([receiver isEqual:_ID], @"receiver error: %@", receiver);
        // get passphrase in personal message
        PW = msg.encryptedKey;
        if (!PW) {
            // get passphrase from contact
            scKey = [store cipherKeyFromContact:sender];
        }
    } else if (receiver.address.network == MKMNetwork_Group) {
        // get passphrase in group message
        PW = [msg.encryptedKeys encryptedKeyForID:_ID];
        if (!PW) {
            // get passphrase from group.member
            scKey = [store cipherKeyFromMember:sender inGroup:receiver];
        }
    }
    
    if (PW) {
        PW = [self decrypt:PW];
        scKey = [[MKMSymmetricKey alloc] initWithJSONString:[PW UTF8String]];
    }
    return scKey;
}

@end
