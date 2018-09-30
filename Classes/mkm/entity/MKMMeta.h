//
//  MKMMeta.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPublicKey;
@class MKMPrivateKey;

@class MKMID;
@class MKMAddress;

/**
 *  Account/Group Meta data
 *
 *      data format: {
 *          version: 1,          // algorithm version
 *          seed: "moKy",        // user/group name
 *          key: "{public key}", // PK = secp256k1(SK);
 *          fingerprint: "..."   // CT = sign(seed, SK);
 *      }
 *
 *      algorithm:
 *          CT = sign(seed, SK);
 *              _h = ripemd160(sha256(CT));
 *              _n = sha256(sha256(0x00 + _h)).suffix(4);
 *          address = base58_encode(0x00 + _h + _n);
 *          number = uint(_n);
 */
@interface MKMMeta : MKMDictionary

/**
 *  algorithm version
 *
 *      0x01 - address algorithm like BitCoin
 *      0x02 - address algorithm like Ethereum
 */
@property (readonly, nonatomic) NSUInteger version;

@property (readonly, strong, nonatomic) const NSString *seed;
@property (readonly, strong, nonatomic) const MKMPublicKey *key;
@property (readonly, strong, nonatomic) const NSData *fingerprint;

+ (instancetype)metaWithMeta:(id)meta;

/**
 *  Copy meta data from JsON String(dictionary)
 */
- (instancetype)initWithJSONString:(const NSString *)jsonString;
- (instancetype)initWithDictionary:(const NSDictionary *)info;

/**
 *  Copy meta data from network
 */
- (instancetype)initWithSeed:(const NSString *)name
                   publicKey:(const MKMPublicKey *)PK
                 fingerprint:(const NSData *)CT
                     version:(NSUInteger)version;

/**
 Generate fingerprint, initialize meta data
 
 @param name - seed for fingerprint
 @param PK - public key, which must match the private key
 @param SK - private key
 @return Meta object
 */
- (instancetype)initWithSeed:(const NSString *)name
                   publicKey:(const MKMPublicKey *)PK
                  privateKey:(const MKMPrivateKey *)SK;

- (BOOL)match:(const MKMID *)ID;
- (BOOL)matchAddress:(const MKMAddress *)address;

@end

NS_ASSUME_NONNULL_END
