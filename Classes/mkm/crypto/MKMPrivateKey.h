//
//  MKMPrivateKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAsymmetricKey.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPublicKey;

/**
 *  AC Private Key
 *
 *      keyInfo format: {
 *          algorithm: "RSA", // ECC, ...
 *          ...
 *      }
 */
@interface MKMPrivateKey : MKMAsymmetricKey <MKMPrivateKey>

/**
 Get public key from private key
 */
@property (readonly, strong, atomic) MKMPublicKey *publicKey;

- (instancetype)initWithJSONString:(const NSString *)json
                         publicKey:(const MKMPublicKey *)PK;

- (BOOL)isEqual:(const MKMPrivateKey *)aKey;

@end

NS_ASSUME_NONNULL_END
