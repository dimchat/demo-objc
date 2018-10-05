//
//  DIMGroup.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMInstantMessage.h"
#import "DIMSecureMessage.h"
#import "DIMEnvelope.h"
#import "DIMMessageContent.h"

#import "DIMGroup.h"

@implementation DIMGroup

- (DIMSecureMessage *)encryptMessage:(const DIMInstantMessage *)msg {
    const DIMEnvelope *env = msg.envelope;
    const MKMID *to = env.receiver;
    NSAssert([to isEqual:_ID], @"recipient error");
    
    const DIMMessageContent *content = msg.content;
    NSAssert(content, @"content cannot be empty");
    
    // 1. JsON
    NSData *json = [content jsonData];
    
    // 2. use a random symmetric key to encrypt the content
    MKMSymmetricKey *scKey = self.passphrase;
    NSAssert(scKey, @"passphrase cannot be empty");
    NSData *CT = [scKey encrypt:json];
    
    // 3. use the group members' PKs to encrypt the symmetric key
    NSData *PW = [scKey jsonData];
    NSDictionary *keys = [self encryptPassphrase:PW];
    
    // 4. create secure message
    return [[DIMSecureMessage alloc] initWithContent:CT
                                            envelope:env
                                          secretKeys:keys];
}

- (NSDictionary *)encryptPassphrase:(const NSData *)PW {
    NSMutableDictionary *mDict;
    mDict = [[NSMutableDictionary alloc] initWithCapacity:[_members count]];
    
    const MKMID *ID;
    const MKMPublicKey *PK;
    NSData *key;
    
    for (id member in _members) {
        if ([member isKindOfClass:[MKMEntity class]]) {
            ID = [(MKMEntity *)member ID];
        } else if ([member isKindOfClass:[MKMID class]]) {
            ID = (MKMID *)member;
        } else {
            NSAssert([member isKindOfClass:[NSString class]], @"member error: %@", member);
            ID = [MKMID IDWithID:member];
        }
        PK = [ID publicKey];
        if (ID && PK) {
            key = [PK encrypt:PW];
            NSAssert(key, @"error");
            [mDict setObject:[key base64Encode] forKey:ID];
        }
    }
    
    return mDict;
}

@end
