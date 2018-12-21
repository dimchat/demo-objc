//
//  DKDSecureMessage.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DKDEncryptedKeyMap : DKDDictionary

- (NSData *)encryptedKeyForID:(const MKMID *)ID;

- (void)setEncryptedKey:(NSData *)key forID:(const MKMID *)ID;

@end

#pragma mark -

@class DKDInstantMessage;

/**
 *  Instant Message encrypted by a symmetric key
 *
 *      data format: {
 *          //-- envelope
 *          sender   : "moki@xxx",
 *          receiver : "hulk@yyy",
 *          time     : 123,
 *          //-- content data & key/keys
 *          data     : "...",  // base64_encode(symmetric)
 *          key      : "...",  // base64_encode(asymmetric)
 *          keys     : []
 *      }
 */
@interface DKDSecureMessage : DKDMessage

@property (readonly, strong, nonatomic) NSData *data;

/**
 * Password to decode the content, which encrypted by contact.PK
 *
 *   secureMessage.content = symmetricKey.encrypt(instantMessage.content);
 *   encryptedKey = receiver.publicKey.encrypt(symmetricKey);
 */
@property (readonly, strong, nonatomic) NSData *encryptedKey;
@property (readonly, strong, nonatomic) DKDEncryptedKeyMap *encryptedKeys;

/**
 Secure Message for Personal

 @param content - Data encrypted with a random symmetic key
 @param env - Message envelope
 @param key - Symmetic key encrypted with receiver's PK
 @return SecureMessage object
 */
- (instancetype)initWithData:(const NSData *)content
                encryptedKey:(const NSData *)key
                    envelope:(const DKDEnvelope *)env
NS_DESIGNATED_INITIALIZER;

/**
 Secure Message for Group

 @param content - Data encrypted with a random symmetic key
 @param env - Message envelope
 @param keys - Symmetic keys encrypted with group members' PKs
 @return SecureMessage object
 */
- (instancetype)initWithData:(const NSData *)content
               encryptedKeys:(const DKDEncryptedKeyMap *)keys
                    envelope:(const DKDEnvelope *)env
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
