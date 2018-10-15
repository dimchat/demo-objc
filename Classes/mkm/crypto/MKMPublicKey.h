//
//  MKMPublicKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAsymmetricKey.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPrivateKey;

/**
 *  AC Public Key
 *
 *      keyInfo format: {
 *          algorithm: "ECC", // RSA, ...
 *          ...
 *      }
 */
@interface MKMPublicKey : MKMAsymmetricKey <MKMPublicKey>

- (BOOL)isMatch:(const MKMPrivateKey *)SK;

@end

NS_ASSUME_NONNULL_END
