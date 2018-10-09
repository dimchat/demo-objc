//
//  MKMKeyStore.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKMSymmetricKey;
@class MKMPublicKey;
@class MKMPrivateKey;

@class MKMEntity;
@class MKMUser;
@class MKMContact;

@interface MKMKeyStore : NSObject

+ (instancetype)sharedStore;

/**
 Get PK for contact to encrypt or verify message

 @param contact - contact with ID
 @return PK
 */
- (const MKMPublicKey *)publicKeyForContact:(const MKMContact *)contact;

- (void)setPublicKey:(const MKMPublicKey *)PK
          forContact:(const MKMContact *)contact;

/**
 Get SK for user to decrypt or sign message

 @param user - user with ID
 @return SK
 */
- (const MKMPrivateKey *)privateKeyForUser:(const MKMUser *)user;

- (void)setPrivateKey:(const MKMPrivateKey *)SK
              forUser:(const MKMUser *)user;

/**
 Get PW for contact or group to encrypt or decrypt message

 @param entity - entity with ID
 @return PW
 */
- (const MKMSymmetricKey *)passphraseForEntity:(const MKMEntity *)entity;

- (void)setPassphrase:(const MKMSymmetricKey *)PW
            forEntity:(const MKMEntity *)entity;

/**
 Get encrypted SK for user to store elsewhere

 @param user - user with ID
 @param scKey - password to encrypt the SK
 @return KS
 */
- (const NSData *)privateKeyStoredForUser:(const MKMUser *)user
                               passphrase:(const MKMSymmetricKey *)scKey;

@end

NS_ASSUME_NONNULL_END
