//
//  DIMCertifiedMessage.h
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMSecureMessage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Instant Message signed by an asymmetric key
 *
 *      data format: {
 *          //-- envelope
 *          sender   : "moki@xxx",
 *          receiver : "hulk@yyy",
 *          time     : 123,
 *          //-- content data & key/keys
 *          data     : "...",  // Base64(symmetric)
 *          key      : "...",  // Base64(asymmetric)
 *          keys     : [],
 *          //-- signature
 *          signature: "..."   // Base64
 *      }
 */
@interface DIMCertifiedMessage : DIMSecureMessage

@property (readonly, strong, nonatomic) NSData *signature;

- (instancetype)initWithData:(const NSData *)content
                   signature:(const NSData *)CT
                encryptedKey:(const NSData *)key
                    envelope:(const DIMEnvelope *)env
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithData:(const NSData *)content
                   signature:(const NSData *)CT
               encryptedKeys:(const DIMEncryptedKeyMap *)keys
                    envelope:(const DIMEnvelope *)env
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
