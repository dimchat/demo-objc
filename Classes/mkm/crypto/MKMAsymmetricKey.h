//
//  MKMAsymmetricKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

#define ACAlgorithmRSA @"RSA"
#define ACAlgorithmECC @"ECC"

/**
 *  Asymmetric Cryptography Keys
 *
 *      acKeyInfo format: {
 *          algorithm: "ECC",
 *          modulus: "....."  // Base64
 *      }
 */
@interface MKMAsymmetricKey : MKMDictionary {
    
    const NSString *_algorithm;
    const NSDictionary *_acKeyInfo;
}

// default: @"ECC"
@property (readonly, strong, nonatomic) const NSString *algorithm;

- (instancetype)initWithJSONString:(const NSString *)json;

- (instancetype)initWithAlgorithm:(const NSString *)algorithm
                          keyInfo:(const NSDictionary *)info;

- (BOOL)isEqual:(const MKMAsymmetricKey *)aKey;

@end

NS_ASSUME_NONNULL_END
