//
//  MKMCryptographyKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Cryptography Key
 *
 *      keyInfo format: {
 *          algorithm: "ECC", // RSA, AES, ...
 *          ...
 *      }
 */
@interface MKMCryptographyKey : MKMDictionary {
    
    const NSString *_algorithm;
}

@property (readonly, strong, nonatomic) const NSString *algorithm;

+ (instancetype)keyWithKey:(id)key;

- (instancetype)initWithJSONString:(const NSString *)json;

- (instancetype)initWithAlgorithm:(const NSString *)algorithm;
- (instancetype)initWithAlgorithm:(const NSString *)algorithm
                          keyInfo:(const NSDictionary *)info;

- (BOOL)isEqual:(const MKMCryptographyKey *)aKey;

@end

NS_ASSUME_NONNULL_END
