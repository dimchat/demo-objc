//
//  DIMGroup.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"

#import "DIMMember.h"

#import "DIMInstantMessage.h"
#import "DIMSecureMessage.h"
#import "DIMEnvelope.h"
#import "DIMMessageContent.h"

#import "DIMKeyStore.h"

#import "DIMGroup.h"

@implementation DIMGroup

- (NSString *)name {
    MKMProfile *profile = MKMProfileForID(_ID);
    NSString *str = profile.name;
    if (str) {
        return str;
    }
    return [super name];
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
    
    // 3. use the group members' PKs to encrypt the symmetric key
    NSData *PW = [scKey jsonData];
    DIMEncryptedKeyMap *keys = [self encryptPassphrase:PW];
    
    // 4. create secure message
    return [[DIMSecureMessage alloc] initWithData:CT
                                    encryptedKeys:keys
                                         envelope:env];
}

- (DIMEncryptedKeyMap *)encryptPassphrase:(const NSData *)PW {
    DIMEncryptedKeyMap *map;
    map = [[DIMEncryptedKeyMap alloc] initWithCapacity:[_members count]];
    
    DIMMember *member;
    NSData *key;
    for (MKMID *ID in _members) {
        member = DIMMemberWithID(ID, _ID);
        NSAssert(member.publicKey, @"failed to get PK for ID: %@", ID);
        if (member.publicKey) {
            key = [member.publicKey encrypt:PW];
            NSAssert(key, @"error");
            [map setEncryptedKey:key forID:ID];
        }
    }
    
    return map;
}

#pragma mark - Passphrase

- (MKMSymmetricKey *)cipherKeyForEncrypt:(const DIMInstantMessage *)msg {
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

@end
