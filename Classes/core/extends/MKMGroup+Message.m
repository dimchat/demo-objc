//
//  MKMGroup+Message.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DIMInstantMessage.h"
#import "DIMSecureMessage.h"
#import "DIMEnvelope.h"
#import "DIMMessageContent.h"

#import "DIMKeyStore.h"

#import "MKMGroup+Message.h"

@implementation MKMGroup (Message)

- (DIMSecureMessage *)encryptMessage:(const DIMInstantMessage *)msg {
    NSAssert([msg.envelope.receiver isEqual:_ID], @"recipient error");
    NSAssert(msg.content, @"content cannot be empty");
    
    // 1. JsON
    NSData *json = [msg.content jsonData];
    
    // 2. use a random symmetric key to encrypt the content
    MKMSymmetricKey *scKey = [self keyForEncryptMessage:msg];
    NSAssert(scKey, @"passphrase cannot be empty");
    NSData *CT = [scKey encrypt:json];
    
    // 3. use the group members' PKs to encrypt the symmetric key
    DIMEncryptedKeyMap *keys = [self secretKeysForKey:scKey];
    
    // 4. create secure message
    return [[DIMSecureMessage alloc] initWithData:CT
                                    encryptedKeys:keys
                                         envelope:msg.envelope];
}

#pragma mark - Passphrase

- (MKMSymmetricKey *)keyForEncryptMessage:(const DIMInstantMessage *)msg {
    DIMKeyStore *store = [DIMKeyStore sharedInstance];
    DIMEnvelope *env = msg.envelope;
    //MKMID *sender = env.sender;
    MKMID *receiver = env.receiver;
    NSAssert([receiver isEqual:_ID], @"receiver error: %@", receiver);
    
    MKMSymmetricKey *PW = [store cipherKeyForGroup:_ID];
    if (!PW) {
        // create a new one
        PW = [[MKMSymmetricKey alloc] init];
        [store setCipherKey:PW forGroup:_ID];
    }
    return PW;
}

- (DIMEncryptedKeyMap *)secretKeysForKey:(const MKMSymmetricKey *)PW {
    DIMEncryptedKeyMap *map;
    map = [[DIMEncryptedKeyMap alloc] initWithCapacity:[_members count]];
    
    MKMMember *member;
    NSData *key;
    for (MKMID *ID in _members) {
        member = MKMMemberWithID(ID, _ID);
        NSAssert(member.publicKey, @"failed to get PK for ID: %@", ID);
        if (member.publicKey) {
            key = [member.publicKey encrypt:[PW jsonData]];
            NSAssert(key, @"error");
            [map setEncryptedKey:key forID:ID];
        }
    }
    
    return map;
}

@end
