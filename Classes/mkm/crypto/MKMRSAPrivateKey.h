//
//  MKMRSAPrivateKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPrivateKey.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  RSA Private Key
 *
 *      keyInfo format: {
 *          algorithm    : "RSA",
 *          keySizeInBits: 1024, // optional
 *          data         : "..." // base64_encode()
 *      }
 */
@interface MKMRSAPrivateKey : MKMPrivateKey

@end

NS_ASSUME_NONNULL_END
