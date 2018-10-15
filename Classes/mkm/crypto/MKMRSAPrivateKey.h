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
 *          algorithm: "RSA",
 *          size: 1024,       // size in bits (optional)
 *          data: "..."       // base64
 *      }
 */
@interface MKMRSAPrivateKey : MKMPrivateKey

- (instancetype)initWithDictionary:(NSDictionary *)info;

@end

NS_ASSUME_NONNULL_END
