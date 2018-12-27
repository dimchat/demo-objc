//
//  DKDInstantMessage+Transform.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/12/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DKDEnvelope.h"
#import "DKDMessageContent.h"
#import "DKDSecureMessage.h"
#import "DKDKeyStore.h"

#import "DKDInstantMessage+Transform.h"

static inline MKMSymmetricKey *get_encrypt_key(const MKMID *receiver) {
    DKDKeyStore *store = [DKDKeyStore sharedInstance];
    MKMSymmetricKey *scKey = nil;
    if (MKMNetwork_IsPerson(receiver.type)) {
        scKey = [store cipherKeyForAccount:receiver];
        if (!scKey) {
            // create a new key & save it into the Key Store
            scKey = [[MKMSymmetricKey alloc] init];
            [store setCipherKey:scKey forAccount:receiver];
        }
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        scKey = [store cipherKeyForGroup:receiver];
        if (!scKey) {
            // create a new key & save it into the Key Store
            scKey = [[MKMSymmetricKey alloc] init];
            [store setCipherKey:scKey forGroup:receiver];
        }
    } else {
        // receiver type not supported
        assert(false);
    }
    return scKey;
}

static inline DKDEncryptedKeyMap *pack_keys(const MKMGroup *group,
                                            const MKMSymmetricKey *key) {
    DKDEncryptedKeyMap *map;
    map = [[DKDEncryptedKeyMap alloc] initWithCapacity:[group.members count]];
    
    MKMMember *member;
    NSData *data;
    for (MKMID *ID in group.members) {
        member = MKMMemberWithID(ID, group.ID);
        assert(member.publicKey);
        data = [member.publicKey encrypt:[key jsonData]];
        assert(data);
        [map setEncryptedKey:data forID:ID];
    }
    return map;
}

@implementation DKDInstantMessage (Transform)

- (DKDSecureMessage *)encrypt {
    MKMID *receiver = self.envelope.receiver;
    
    // 1. symmetric key
    MKMSymmetricKey *scKey = get_encrypt_key(receiver);
    
    // 2. encrypt 'content' to 'data'
    NSData *json = [self.content jsonData];
    NSData *CT = [scKey encrypt:json];
    
    // 3. encrypt 'key'
    NSData *key = [scKey jsonData];
    DKDSecureMessage *sMsg = nil;
    if (MKMNetwork_IsPerson(receiver.type)) {
        MKMContact *contact = MKMContactWithID(receiver);
        key = [contact.publicKey encrypt:key];
        sMsg = [[DKDSecureMessage alloc] initWithData:CT
                                         encryptedKey:key
                                             envelope:self.envelope];
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        MKMGroup *group = MKMGroupWithID(receiver);
        DKDEncryptedKeyMap *keys = pack_keys(group, scKey);
        sMsg = [[DKDSecureMessage alloc] initWithData:CT
                                        encryptedKeys:keys
                                             envelope:self.envelope];
    } else {
        NSAssert(false, @"receiver error: %@", receiver);
    }
    
    NSAssert(sMsg, @"encrypt message error: %@", self);
    return sMsg;
}

@end
