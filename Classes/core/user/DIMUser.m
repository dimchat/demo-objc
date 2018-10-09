//
//  DIMUser.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMInstantMessage.h"
#import "DIMSecureMessage.h"
#import "DIMCertifiedMessage.h"
#import "DIMEnvelope.h"
#import "DIMMessageContent.h"

#import "DIMUser.h"

@implementation DIMUser

- (DIMInstantMessage *)decryptMessage:(const DIMSecureMessage *)msg {
    const DIMEnvelope *env = msg.envelope;
    NSAssert([env.receiver isEqual:_ID], @"recipient error");
    
    // 1. use the user's private key to decrypt the symmetric key
    const NSData *PW = msg.secretKey;
    NSAssert(PW, @"secret key cannot be empty");
    PW = [self decrypt:PW];
    
    // 2. use the symmetric key to decrypt the content
    MKMSymmetricKey *scKey;
    scKey = [[MKMSymmetricKey alloc] initWithJSONString:[PW UTF8String]];
    const NSData *CT = [scKey decrypt:msg.content];
    
    // 3. JsON
    NSString *json = [CT UTF8String];
    DIMMessageContent *content;
    content = [[DIMMessageContent alloc] initWithJSONString:json];
    
    // 4. create instant message
    return [[DIMInstantMessage alloc] initWithContent:content
                                             envelope:env];
}

- (DIMCertifiedMessage *)signMessage:(const DIMSecureMessage *)msg {
    const DIMEnvelope *env = msg.envelope;
    NSAssert([env.sender isEqual:_ID], @"sender error");
    
    const NSData *content = msg.content;
    NSAssert(content, @"content cannot be empty");
    
    // 1. use the user's private key to sign the content
    const NSData *CT = [self sign:content];
    
    // 2. create certified message
    DIMCertifiedMessage *cMsg = nil;
    if (env.receiver.address.network == MKMNetwork_Main) {
        // Personal Message
        const NSData *key = msg.secretKey;
        NSAssert(key, @"secret key not found");
        cMsg = [[DIMCertifiedMessage alloc] initWithContent:content
                                                   envelope:env
                                                  secretKey:key
                                                  signature:CT];
    } else if (env.receiver.address.network == MKMNetwork_Group) {
        // Group Message
        const NSDictionary *keys = msg.secretKeys;
        NSAssert(keys, @"secret keys not found");
        cMsg = [[DIMCertifiedMessage alloc] initWithContent:content
                                                   envelope:env
                                                 secretKeys:keys
                                                  signature:CT];
    }
    return cMsg;
}

#pragma mark - Decrypt/Sign functions for passphrase/signature

- (NSData *)decrypt:(const NSData *)ciphertext {
    MKMKeyStore *store = [MKMKeyStore sharedStore];
    const MKMPrivateKey *SK = [store privateKeyForUser:self];
    return [SK decrypt:ciphertext];
}

- (NSData *)sign:(const NSData *)plaintext {
    MKMKeyStore *store = [MKMKeyStore sharedStore];
    const MKMPrivateKey *SK = [store privateKeyForUser:self];
    return [SK sign:plaintext];
}

@end
