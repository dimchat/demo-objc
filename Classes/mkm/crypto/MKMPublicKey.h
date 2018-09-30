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

/**
 *  AC Public Key
 *
 *      keyInfo format: {
 *          algorithm: "ECC", // RSA, ...
 *          ...
 *      }
 */
@interface MKMPublicKey : MKMAsymmetricKey <MKMPublicKey>

- (instancetype)initWithAlgorithm:(const NSString *)algorithm
                          keyInfo:(const NSDictionary *)info;

- (BOOL)isMatch:(const MKMPrivateKey *)SK;

@end

NS_ASSUME_NONNULL_END
