//
//  DIMContact.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMContact.h"

@implementation DIMContact

- (DIMSecureMessage *)encryptMessage:(const DIMInstantMessage *)message {
    return nil;
}

- (NSData *)encrypt:(const NSData *)plaintext {
    const MKMPublicKey *PK = self.ID.publicKey;
    return [PK encrypt:plaintext];
}

- (BOOL)verify:(const NSData *)plaintext
     signature:(const NSData *)ciphertext {
    const MKMPublicKey *PK = self.ID.publicKey;
    return [PK verify:plaintext signature:ciphertext];
}

@end
