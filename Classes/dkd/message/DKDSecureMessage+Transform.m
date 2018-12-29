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

#import "DKDSecureMessage+Packing.h"

#import "DKDKeyStore.h"

#import "DKDSecureMessage+Transform.h"

@implementation DKDSecureMessage (Transform)

- (DKDInstantMessage *)decrypt {
    DKDKeyStore *store = [DKDKeyStore sharedInstance];
    MKMID *sender = self.envelope.sender;
    MKMID *receiver = self.envelope.receiver;
    
    // 1. symmetric key
    MKMSymmetricKey *scKey = nil;
    NSData *key = nil;
    if (MKMNetwork_IsPerson(receiver.type)) {
        key = self.encryptedKey;
        if (key) {
            // 1.1. decrypt passphrase with user's private key
            MKMUser *user = MKMUserWithID(receiver);
            key = [user.privateKey decrypt:key];
            if (key) {
                NSString *json = [key UTF8String];
                scKey = [[MKMSymmetricKey alloc] initWithJSONString:json];
            } else {
                NSAssert(false, @"decrypt key failed");
            }
        } else {
            // 1.2. get passphrase from the Key Store
            MKMID *group = self.group;
            if (group) {
                scKey = [store cipherKeyFromMember:sender inGroup:group];
            } else {
                scKey = [store cipherKeyFromAccount:sender];
            }
        }
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        NSAssert(false, @"trim group message for a member first");
        return nil;
    } else {
        NSAssert(false, @"receiver type not supported");
        return nil;
    }
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
    
    // 2.1. Check group
    // if message.group exists, it must equal to content.group
    NSAssert(!self.group ||
             [content.group isEqual:self.group],
             @"error");
    // if content.group exists, it should equal to the message.receiver
    // or the message.receiver must be a member of this group
    NSAssert(!content.group ||
             [content.group isEqual:receiver] ||
             [MKMGroupWithID(content.group) isMember:receiver],
             @"group error");
    
    // 3. update encrypted key for contact/group.member
    if (key) {
        MKMID *group = content.group;
        if (group) {
            [store setCipherKey:scKey fromMember:sender inGroup:receiver];
        } else {
            [store setCipherKey:scKey fromAccount:sender];
        }
    }
    
    // 4. create instant message
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
        MKMID *group = self.group;
        if (rMsg && group) {
            rMsg.group = group; // copy group
        }
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
