//
//  MKMKeyStore.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMKeyStore : NSObject

@property (readonly, strong, nonatomic) const NSString *algorithm;

@property (readonly, strong, nonatomic) const MKMPrivateKey *privateKey;
@property (readonly, strong, nonatomic) const MKMPublicKey *publicKey;


/**
 Generate key pairs

 @param name - Asymmetric cryptography algorithm
 @return KeyStore object
 */
- (instancetype)initWithAlgorithm:(const NSString *)name;

/**
 Initialize with key pairs

 @param PK - public key
 @param SK - private key
 @return KeyStore object
 */
- (instancetype)initWithPublicKey:(const MKMPublicKey *)PK
                       privateKey:(const MKMPrivateKey *)SK
NS_DESIGNATED_INITIALIZER;

- (NSData *)storeKey:(const NSString *)passphrase;

@end

NS_ASSUME_NONNULL_END
