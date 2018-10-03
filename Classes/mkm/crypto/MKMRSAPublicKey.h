//
//  MKMRSAPublicKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  RSA Public Key
 *
 *      keyInfo format: {
 *          algorithm: "RSA",
 *          data: "..."
 *      }
 */
@interface MKMRSAPublicKey : MKMPublicKey

@end

NS_ASSUME_NONNULL_END
