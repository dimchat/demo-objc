//
//  MKMGroup+Message.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DKDInstantMessage.h"
#import "DKDSecureMessage.h"
#import "DKDEnvelope.h"
#import "DKDMessageContent.h"

#import "DKDKeyStore.h"

#import "MKMGroup+Message.h"

@implementation MKMGroup (Message)

- (DKDSecureMessage *)encryptMessage:(const DKDInstantMessage *)msg {
    NSAssert([msg.envelope.receiver isEqual:_ID], @"recipient error");
    NSAssert(msg.content, @"content cannot be empty");
    
    // 1. JsON
    NSData *json = [msg.content jsonData];
    
    // 2. use a random symmetric key to encrypt the content
    MKMSymmetricKey *scKey = [self keyForEncryptMessage:msg];
    NSAssert(scKey, @"passphrase cannot be empty");
    NSData *CT = [scKey encrypt:json];
    
    // 3. use the group members' PKs to encrypt the symmetric key
    DKDEncryptedKeyMap *keys = [self secretKeysForKey:scKey];
    
    // 4. create secure message
    return [[DKDSecureMessage alloc] initWithData:CT
                                    encryptedKeys:keys
                                         envelope:msg.envelope];
}

#pragma mark - Passphrase

- (MKMSymmetricKey *)keyForEncryptMessage:(const DKDInstantMessage *)msg {
    DKDKeyStore *store = [DKDKeyStore sharedInstance];
    DKDEnvelope *env = msg.envelope;
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

- (DKDEncryptedKeyMap *)secretKeysForKey:(const MKMSymmetricKey *)PW {
    DKDEncryptedKeyMap *map;
    map = [[DKDEncryptedKeyMap alloc] initWithCapacity:[_members count]];
    
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
