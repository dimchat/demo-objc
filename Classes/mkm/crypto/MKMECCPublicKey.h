//
//  MKMECCPublicKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  ECC Public Key
 *
 *      keyInfo format: {
 *          algorithm: "ECC",
 *          ...
 *      }
 */
@interface MKMECCPublicKey : MKMPublicKey

- (instancetype)initWithDictionary:(NSDictionary *)info;

@end

NS_ASSUME_NONNULL_END
