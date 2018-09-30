//
//  MKMPrivateKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMAsymmetricKey.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPublicKey;

@protocol MKMPrivateKey

/**
 Get public key from private key

 @return public key
 */
- (const MKMPublicKey *)publicKey;

/**
 *  signature = sign(text, SK);
 */
- (NSData *)sign:(const NSData *)plaintext;

/**
 *  text = decrypt(CT, SK);
 */
- (NSData *)decrypt:(const NSData *)ciphertext;

@end

@interface MKMPrivateKey : MKMAsymmetricKey<MKMPrivateKey>

- (instancetype)initWithJSONString:(const NSString *)json
                         publicKey:(const MKMPublicKey *)PK;

- (instancetype)initWithAlgorithm:(const NSString *)algorithm
                          keyInfo:(const NSDictionary *)info;

@end

NS_ASSUME_NONNULL_END
