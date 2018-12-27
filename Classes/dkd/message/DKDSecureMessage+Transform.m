//
//  DKDSecureMessage+Transform.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/12/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DKDEnvelope.h"
#import "DKDMessageContent.h"
#import "DKDInstantMessage.h"
#import "DKDReliableMessage.h"

#import "DKDKeyStore.h"

#import "DKDSecureMessage+Transform.h"

static inline MKMSymmetricKey *_decrypt_key(const NSData *data,
                                            const MKMPrivateKey *SK) {
    NSData *key = [SK decrypt:data];
    NSString *json = [key UTF8String];
    return [[MKMSymmetricKey alloc] initWithJSONString:json];
}

static inline MKMSymmetricKey *get_decrypt_key(const MKMUser *user,
                                               const DKDSecureMessage *sMsg) {
    DKDKeyStore *store = [DKDKeyStore sharedInstance];
    DKDEnvelope *env = sMsg.envelope;
    MKMID *sender = env.sender;
    MKMID *receiver = env.receiver;
    
    MKMSymmetricKey *scKey;
    NSData *key = nil;
    if (MKMNetwork_IsPerson(receiver.type)) {
        assert([user.ID isEqual:receiver]);
        // check passphrase in personal message
        key = sMsg.encryptedKey;
        if (key) {
            // decrypt & save the key into the Key Store
            scKey = _decrypt_key(key, user.privateKey);
            [store setCipherKey:scKey fromAccount:sender];
        } else {
            // get passphrase from contact in the Key Store
            scKey = [store cipherKeyFromAccount:sender];
        }
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        // check passphrase in group message
        key = [sMsg.encryptedKeys encryptedKeyForID:user.ID];
        if (key) {
            // decrypt & save the key into the Key Store
            scKey = _decrypt_key(key, user.privateKey);
            [store setCipherKey:scKey fromMember:sender inGroup:receiver];
        } else {
            // get passphrase from group.member in the Key Store
            scKey = [store cipherKeyFromMember:sender inGroup:receiver];
        }
    } else {
        // receiver type not supported
        assert(false);
    }
    return scKey;
}

@implementation DKDSecureMessage (Transform)

- (DKDInstantMessage *)decrypt {
    MKMID *receiver = self.envelope.receiver;
    NSAssert(MKMNetwork_IsPerson(receiver.type), @"receiver error");
    MKMUser *user = MKMUserWithID(receiver);
    
    // 1. symmetric key
    MKMSymmetricKey *scKey = get_decrypt_key(user, self);
    NSAssert(scKey, @"failed to get decrypt key for receiver: %@", receiver);
    
    // 2. decrypt 'data' to 'content'
    NSData *data = [scKey decrypt:self.data];
    if (!data) {
        NSAssert(false, @"failed to decrypt secure data: %@", self);
        return nil;
    }
    NSString *json = [data UTF8String];
    DKDMessageContent *content;
    content = [[DKDMessageContent alloc] initWithJSONString:json];
    
    // 3. create instant message
    DKDInstantMessage *iMsg;
    iMsg = [[DKDInstantMessage alloc] initWithContent:content
                                             envelope:self.envelope];
    return iMsg;
}

- (DKDReliableMessage *)sign {
    MKMID *sender = self.envelope.sender;
    MKMID *receiver = self.envelope.receiver;
    NSAssert(MKMNetwork_IsPerson(sender.type), @"sender error");
    MKMUser *user = MKMUserWithID(sender);
    
    // 1. sign the content data with user's private key
    NSData *CT = [user.privateKey sign:self.data];
    if (!CT) {
        NSAssert(false, @"failed to sign data: %@", self);
        return nil;
    }
    
    // 2. create reliable message
    DKDReliableMessage *rMsg = nil;
    if (MKMNetwork_IsPerson(receiver.type)) {
        // personal message
        rMsg = [[DKDReliableMessage alloc] initWithData:self.data
                                              signature:CT
                                           encryptedKey:self.encryptedKey envelope:self.envelope];
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        // group message
        rMsg = [[DKDReliableMessage alloc] initWithData:self.data
                                              signature:CT
                                          encryptedKeys:self.encryptedKeys
                                               envelope:self.envelope];
    } else {
        NSAssert(false, @"receiver error: %@", receiver);
    }
    
    NSAssert(rMsg, @"sign message error: %@", self);
    return rMsg;
}

@end
