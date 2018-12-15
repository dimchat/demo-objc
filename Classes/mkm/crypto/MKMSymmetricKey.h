//
//  MKMSymmetricKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMCryptographyKey.h"

NS_ASSUME_NONNULL_BEGIN

#define SCAlgorithmAES @"AES"
#define SCAlgorithmDES @"DES"

@protocol MKMSymmetricKey <NSObject>
@optional

/**
 *  CT = encrypt(text, PW)
 */
- (NSData *)encrypt:(const NSData *)plaintext;

/**
 *  text = decrypt(CT, PW);
 */
- (NSData *)decrypt:(const NSData *)ciphertext;

@end

/**
 *  Symmetric Cryptography Key
 *
 *      keyInfo format: {
 *          algorithm: "AES",
 *          ...
 *      }
 */
@interface MKMSymmetricKey : MKMCryptographyKey <MKMSymmetricKey>

@end

NS_ASSUME_NONNULL_END
