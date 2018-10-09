//
//  DIMTransceiver.h
//  DIM
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMEnvelope.h"
#import "DIMMessageContent.h"
#import "DIMCertifiedMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMTransceiver : NSObject

+ (instancetype)sharedInstance;

- (DIMUser *)userFromID:(const MKMID *)ID;
- (DIMContact *)contactFromID:(const MKMID *)ID;
- (DIMGroup *)groupFromID:(const MKMID *)ID;

#pragma mark - prepare message for sending out

/**
 Transform an instant message to certified

 @param message - InstantMessage object
 @return CertifiedMessage object
 */
- (DIMCertifiedMessage *)certifiedMessageWithInstantMessage:(const DIMInstantMessage *)message;

/**
 Pack message content with envelope, transform to certified message

 @param content - message content
 @param env - envelope
 @return CertifiedMessage object
 */
- (DIMCertifiedMessage *)certifiedMessageWithContent:(const DIMMessageContent *)content envelope:(const DIMEnvelope *)env;

/**
 Pack message content with sender and receiver, transform it

 @param content - message content
 @param sender - sender ID
 @param receiver - receiver ID
 @return CertifiedMessage Object
 */
- (DIMCertifiedMessage *)certifiedMessageWithContent:(const DIMMessageContent *)content sender:(const MKMID *)sender receiver:(const MKMID *)receiver;

#pragma mark - extract message after received

/**
 Extract instant message from a certified message

 @param message - certified message
 @return InstantMessage object
 */
- (DIMInstantMessage *)instantMessageFromCertifiedMessage:(const DIMCertifiedMessage *)message;

/**
 Extract message content from a certified message

 @param message - certified message
 @return MessageContent object
 */
- (DIMMessageContent *)contentFromCertifiedMessage:(const DIMCertifiedMessage *)message;

@end

NS_ASSUME_NONNULL_END
