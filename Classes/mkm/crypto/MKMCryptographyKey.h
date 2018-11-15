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
 *          algorithm: "RSA", // ECC, AES, ...
 *          ...
 *      }
 */
@interface MKMCryptographyKey : MKMDictionary

@property (readonly, strong, nonatomic) NSString *algorithm;

+ (instancetype)keyWithKey:(id)key;

- (instancetype)initWithDictionary:(NSDictionary *)keyInfo
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithJSONString:(const NSString *)json;

- (instancetype)initWithAlgorithm:(const NSString *)algorithm;

- (BOOL)isEqual:(const MKMCryptographyKey *)aKey;

@end

@interface MKMCryptographyKey (PersistentStore)

+ (instancetype)loadKeyWithIdentifier:(const NSString *)identifier;

- (BOOL)saveKeyWithIdentifier:(const NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
