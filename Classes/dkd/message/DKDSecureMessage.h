//
//  DKDSecureMessage.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class DKDEncryptedKeyMap;
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
 *          keys     : {
 *              "ID1": "key1", // base64_encode(asymmetric)
 *          }
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
@property (readonly, strong, nonatomic, nullable) NSData *encryptedKey;
@property (readonly, strong, nonatomic, nullable) DKDEncryptedKeyMap *encryptedKeys;

/**
 Secure Message for Personal

 @param content - Data encrypted with a random symmetic key
 @param env - Message envelope
 @param key - Symmetic key encrypted with receiver's PK
 @return SecureMessage object
 */
- (instancetype)initWithData:(const NSData *)content
                encryptedKey:(nullable const NSData *)key
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
               encryptedKeys:(nullable const DKDEncryptedKeyMap *)keys
                    envelope:(const DKDEnvelope *)env
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

#pragma mark -

/**
 *  Encrypted Key Map for Group Message
 *
 *      data format: {
 *          "ID1": "{key1}", // base64_encode(asymmetric)
 *      }
 */
@interface DKDEncryptedKeyMap : DKDDictionary

+ (instancetype)mapWithMap:(id)map;

- (NSData *)encryptedKeyForID:(const MKMID *)ID;

- (void)setEncryptedKey:(NSData *)key forID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
