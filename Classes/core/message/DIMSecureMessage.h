//
//  DIMSecureMessage.h
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
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
 *          //-- key
 *          secretKey: "..."   // Base64(asmmetric)
 *      }
 */
@interface DIMSecureMessage : DIMDictionary

@property (readonly, strong, nonatomic) const DIMEnvelope *envelope;
@property (readonly, strong, nonatomic) const NSData *content;

/**
 * Password to decode the content, which encrypted by contact.PK
 *
 *   secureMessage.content = symmetricKey.encrypt(instantMessage.content);
 *   secretKey = contact.privateKey.encrypt(symmetricKey);
 */
@property (readonly, strong, nonatomic) const NSData *secretKey;

- (instancetype)initWithContent:(const NSData *)content
                       envelope:(const DIMEnvelope *)env
                      secretKey:(const NSData *)key
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
