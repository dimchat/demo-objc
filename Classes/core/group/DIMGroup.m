//
//  DIMGroup.m
//  DIM
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

#import "DIMGroup.h"

@implementation DIMGroup

+ (instancetype)groupWithID:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Group, @"address error");
    MKMConsensus *cons = [MKMConsensus sharedInstance];
    MKMEntityManager *em = [MKMEntityManager sharedManager];
    MKMMeta *meta = [em metaWithID:ID];
    MKMHistory *history = [em historyWithID:ID];
    DIMGroup *group = [[DIMGroup alloc] initWithID:ID meta:meta];
    if (group) {
        group.historyDelegate = cons;
        NSUInteger count = [group runHistory:history];
        NSAssert(count == history.count, @"history error");
    }
    return group;
}

- (MKMSymmetricKey *)passphrase {
    DIMKeyStore *store = [DIMKeyStore sharedStore];
    return [store passphraseForEntity:self];
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
    
    MKMEntityManager *em = [MKMEntityManager sharedManager];
    MKMID *ID;
    MKMPublicKey *PK;
    NSData *key;
    
    for (id member in _members) {
        if ([member isKindOfClass:[MKMEntity class]]) {
            ID = [member ID];
        } else {
            ID = [MKMID IDWithID:member];
        }
        
        PK = [em metaWithID:ID].key;
        if (ID && PK) {
            key = [PK encrypt:PW];
            NSAssert(key, @"error");
            [mDict setObject:[key base64Encode] forKey:ID];
        }
    }
    
    return mDict;
}

@end
