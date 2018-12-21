//
//  MKMAccount+Message.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/11/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DKDEnvelope.h"
#import "DKDMessageContent.h"
#import "DKDInstantMessage.h"
#import "DKDSecureMessage.h"
#import "DKDReliableMessage.h"

#import "DKDKeyStore.h"

#import "MKMAccount+Message.h"

@implementation MKMAccount (Message)

- (DKDSecureMessage *)encryptMessage:(const DKDInstantMessage *)iMsg {
    NSAssert([iMsg.envelope.receiver isEqual:_ID], @"recipient error");
    NSAssert(iMsg.content, @"content cannot be empty");
    
    // 1. JsON
    NSData *json = [iMsg.content jsonData];
    
    // 2. use a random symmetric key to encrypt the content
    MKMSymmetricKey *scKey = [self keyForEncryptMessage:iMsg];
    NSAssert(scKey, @"passphrase cannot be empty");
    NSData *CT = [scKey encrypt:json];
    
    // 3. use the contact's public key to encrypt the symmetric key
    NSData *PW = [scKey jsonData];
    PW = [self.publicKey encrypt:PW];
    
    // 4. create secure message
    return [[DKDSecureMessage alloc] initWithData:CT
                                     encryptedKey:PW
                                         envelope:iMsg.envelope];
}

- (DKDSecureMessage *)verifyMessage:(const DKDReliableMessage *)rMsg {
    NSAssert([rMsg.envelope.sender isEqual:_ID], @"sender error");
    NSAssert(rMsg.data, @"content data cannot be empty");
    NSAssert(rMsg.signature, @"signature cannot be empty");
    NSAssert(rMsg.encryptedKey, @"encrypted key cannot be empty");
    
    // 1. use the contact's public key to verify the signature
    if (![self.publicKey verify:rMsg.data withSignature:rMsg.signature]) {
        // signature error
        return nil;
    }
    
    // 2. create secure message
    return [[DKDSecureMessage alloc] initWithData:rMsg.data
                                     encryptedKey:rMsg.encryptedKey
                                         envelope:rMsg.envelope];
}

#pragma mark - Passphrase

- (MKMSymmetricKey *)keyForEncryptMessage:(const DKDInstantMessage *)iMsg {
    DKDKeyStore *store = [DKDKeyStore sharedInstance];
    DKDEnvelope *env = iMsg.envelope;
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
