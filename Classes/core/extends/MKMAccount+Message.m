//
//  MKMAccount+Message.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DIMEnvelope.h"
#import "DIMMessageContent.h"
#import "DIMInstantMessage.h"
#import "DIMSecureMessage.h"
#import "DIMCertifiedMessage.h"

#import "DIMKeyStore.h"

#import "MKMAccount+Message.h"

@implementation MKMAccount (Message)

- (DIMSecureMessage *)encryptMessage:(const DIMInstantMessage *)msg {
    NSAssert([msg.envelope.receiver isEqual:_ID], @"recipient error");
    NSAssert(msg.content, @"content cannot be empty");
    
    // 1. JsON
    NSData *json = [msg.content jsonData];
    
    // 2. use a random symmetric key to encrypt the content
    MKMSymmetricKey *scKey = [self keyForEncryptMessage:msg];
    NSAssert(scKey, @"passphrase cannot be empty");
    NSData *CT = [scKey encrypt:json];
    
    // 3. use the contact's public key to encrypt the symmetric key
    NSData *PW = [scKey jsonData];
    PW = [self.publicKey encrypt:PW];
    
    // 4. create secure message
    return [[DIMSecureMessage alloc] initWithData:CT
                                     encryptedKey:PW
                                         envelope:msg.envelope];
}

- (DIMSecureMessage *)verifyMessage:(const DIMCertifiedMessage *)msg {
    NSAssert([msg.envelope.sender isEqual:_ID], @"sender error");
    NSAssert(msg.data, @"content data cannot be empty");
    NSAssert(msg.signature, @"signature cannot be empty");
    NSAssert(msg.encryptedKey, @"encrypted key cannot be empty");
    
    // 1. use the contact's public key to verify the signature
    if (![self.publicKey verify:msg.data withSignature:msg.signature]) {
        // signature error
        return nil;
    }
    
    // 2. create secure message
    return [[DIMSecureMessage alloc] initWithData:msg.data
                                     encryptedKey:msg.encryptedKey
                                         envelope:msg.envelope];
}

#pragma mark - Passphrase

- (MKMSymmetricKey *)keyForEncryptMessage:(const DIMInstantMessage *)msg {
    DIMKeyStore *store = [DIMKeyStore sharedInstance];
    DIMEnvelope *env = msg.envelope;
    //MKMID *sender = env.sender;
    MKMID *receiver = env.receiver;
    NSAssert([receiver isEqual:_ID], @"receiver error: %@", receiver);
    
    MKMSymmetricKey *PW = [store cipherKeyForAccount:_ID];
    if (!PW) {
        // create a new one
        PW = [[MKMSymmetricKey alloc] init];
        [store setCipherKey:PW forAccount:_ID];
    }
    return PW;
}

@end
