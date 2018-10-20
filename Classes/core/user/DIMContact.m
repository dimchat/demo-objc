//
//  DIMContact.m
//  DIM
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

#import "DIMKeyStore.h"

#import "DIMContact.h"

@implementation DIMContact

+ (instancetype)contactWithID:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Main, @"address error");
    MKMEntityManager *eman = [MKMEntityManager sharedInstance];
    id<MKMEntityHistoryDelegate> delegate = [MKMConsensus sharedInstance];
    
    MKMMeta *meta = [eman metaForID:ID];
    MKMHistory *history = [eman historyForID:ID];
    DIMContact *contact = [[DIMContact alloc] initWithID:ID meta:meta];
    if (contact) {
        contact.historyDelegate = delegate;
        NSUInteger count = [contact runHistory:history];
        NSAssert(count == history.count, @"history error");
    }
    return contact;
}

- (DIMSecureMessage *)encryptMessage:(const DIMInstantMessage *)msg {
    DIMEnvelope *env = msg.envelope;
    MKMID *to = env.receiver;
    NSAssert([to isEqual:_ID], @"recipient error");
    
    DIMMessageContent *content = msg.content;
    NSAssert(content, @"content cannot be empty");
    
    // 1. JsON
    NSData *json = [content jsonData];
    
    // 2. use a random symmetric key to encrypt the content
    MKMSymmetricKey *scKey = [self cipherKeyForEncrypt:msg];
    NSAssert(scKey, @"passphrase cannot be empty");
    NSData *CT = [scKey encrypt:json];
    
    // 3. use the contact's public key to encrypt the symmetric key
    NSData *PW = [scKey jsonData];
    PW = [self encrypt:PW];
    
    // 4. create secure message
    return [[DIMSecureMessage alloc] initWithData:CT
                                         envelope:env
                                     encryptedKey:PW];
}

- (DIMSecureMessage *)verifyMessage:(const DIMCertifiedMessage *)msg {
    DIMEnvelope *env = msg.envelope;
    MKMID *from = env.sender;
    NSAssert([from isEqual:_ID], @"sender error");
    
    NSData *content = msg.data;
    NSAssert(content, @"content cannot be empty");
    NSData *CT = msg.signature;
    NSAssert(CT, @"signature cannot be empty");
    
    // 1. use the contact's public key to verify the signature
    if (![self verify:content signature:CT]) {
        // signature error
        return nil;
    }
    
    NSData *PW = msg.encryptedKey;
    NSAssert(PW, @"encrypted key cannot be empty");
    
    // 2. create secure message
    return [[DIMSecureMessage alloc] initWithData:content
                                         envelope:env
                                     encryptedKey:PW];
}

#pragma mark - Encrypt/Verify functions for passphrase/signature

- (NSData *)encrypt:(const NSData *)plaintext {
    MKMPublicKey *PK = self.publicKey;
    return [PK encrypt:plaintext];
}

- (BOOL)verify:(const NSData *)plaintext
     signature:(const NSData *)ciphertext {
    MKMPublicKey *PK = self.publicKey;
    return [PK verify:plaintext signature:ciphertext];
}

@end

@implementation DIMContact (Passphrase)

- (MKMSymmetricKey *)cipherKeyForEncrypt:(const DIMInstantMessage *)msg {
    DIMKeyStore *store = [DIMKeyStore sharedInstance];
    DIMEnvelope *env = msg.envelope;
    //MKMID *sender = env.sender;
    MKMID *receiver = env.receiver;
    NSAssert([receiver isEqual:_ID], @"receiver error: %@", receiver);
    
    MKMSymmetricKey *PW = [store cipherKeyForContact:_ID];
    if (!PW) {
        // create a new one
        PW = [[MKMSymmetricKey alloc] init];
        [store setCipherKey:PW forContact:_ID];
    }
    return PW;
}

@end
