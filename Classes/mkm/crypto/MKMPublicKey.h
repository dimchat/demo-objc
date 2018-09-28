//
//  MKMPublicKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKMAsymmetricKey.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPrivateKey;

@interface MKMPublicKey : MKMAsymmetricKey

/**
 *  CT = encrypt(text, PK)
 */
- (NSData *)encrypt:(const NSData *)plaintext;

/**
 *  OK = verify(text, signature, PK)
 */
- (BOOL)verify:(const NSData *)plaintext
     signature:(const NSData *)ciphertext;

- (BOOL)isMatch:(const MKMPrivateKey *)SK;

@end

NS_ASSUME_NONNULL_END
