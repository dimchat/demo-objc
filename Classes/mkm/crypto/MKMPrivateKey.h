//
//  MKMPrivateKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMAsymmetricKey.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPublicKey;

@interface MKMPrivateKey : MKMAsymmetricKey

@property (readonly, strong, nonatomic) const MKMPublicKey *publicKey;

- (instancetype)initWithJSONString:(const NSString *)json
                         publicKey:(const MKMPublicKey *)PK;

/**
 *  signature = sign(text, SK);
 */
- (NSData *)sign:(const NSData *)plaintext;

/**
 *  text = decrypt(CT, SK);
 */
- (NSData *)decrypt:(const NSData *)ciphertext;

@end

NS_ASSUME_NONNULL_END
