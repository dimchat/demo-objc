//
//  DIMSecureMessage.h
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMEnvelope;
@class DIMInstantMessage;

/**
 *  Instant Message encrypted by a symmetric key
 *
 *      data format: {
 *          //-- envelope
 *          sender   : "moki@xxx",
 *          receiver : "hulk@yyy",
 *          time     : 123,
 *          //-- content
 *          content  : "...",  // Base64(symmetric)
 *          //-- key/keys
 *          key      : "...",  // Base64(asymmetric)
 *          keys     : []
 *      }
 */
@interface DIMSecureMessage : DIMDictionary

@property (readonly, strong, nonatomic) DIMEnvelope *envelope;
@property (readonly, strong, nonatomic) NSData *content;

/**
 * Password to decode the content, which encrypted by contact.PK
 *
 *   secureMessage.content = symmetricKey.encrypt(instantMessage.content);
 *   encryptedKey = contact.privateKey.encrypt(symmetricKey);
 */
@property (readonly, strong, nonatomic) NSData *encryptedKey;
@property (readonly, strong, nonatomic) NSDictionary *encryptedKeys;

/**
 Secure Message for Personal

 @param content - Data encrypted with a random symmetic key
 @param env - Message envelope
 @param key - Symmetic key encrypted with receiver's public key
 @return SecureMessage object
 */
- (instancetype)initWithContent:(const NSData *)content
                       envelope:(const DIMEnvelope *)env
                   encryptedKey:(const NSData *)key
NS_DESIGNATED_INITIALIZER;

/**
 Secure Message for Group

 @param content - Data encrypted with a random symmetic key
 @param env - Message envelope
 @param keys - Symmetic keys encrypted with group member's PKs
 @return SecureMessage object
 */
- (instancetype)initWithContent:(const NSData *)content
                       envelope:(const DIMEnvelope *)env
                  encryptedKeys:(const NSDictionary *)keys
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
