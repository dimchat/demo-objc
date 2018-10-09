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

/**
 *  AC Private Key
 *
 *      keyInfo format: {
 *          algorithm: "ECC", // RSA, ...
 *          ...
 *      }
 */
@interface MKMPrivateKey : MKMAsymmetricKey <MKMPrivateKey>

- (instancetype)initWithJSONString:(const NSString *)json
                         publicKey:(const MKMPublicKey *)PK;

- (instancetype)initWithAlgorithm:(const NSString *)algorithm
                          keyInfo:(const NSDictionary *)info;

- (BOOL)isEqual:(const MKMPrivateKey *)aKey;

/**
 Get public key from private key
 
 @return public key
 */
- (const MKMPublicKey *)publicKey;

@end

NS_ASSUME_NONNULL_END
