//
//  DIMTransceiver.h
//  DIM
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMTransceiver : NSObject

+ (instancetype)sharedInstance;

/**
 Pack message content with sender and receiver to deliver it

 @param content - message content
 @param sender - sender ID
 @param receiver - receiver ID
 @return CertifiedMessage Object
 */
- (DIMCertifiedMessage *)encryptAndSignContent:(const DIMMessageContent *)content
                                        sender:(const MKMID *)sender
                                      receiver:(const MKMID *)receiver;

/**
 Extract instant message from a certified message

 @param cMsg - certified message
 @return InstantMessage object
 */
- (DIMInstantMessage *)verifyAndDecryptMessage:(const DIMCertifiedMessage *)cMsg;

#pragma mark -

- (DIMSecureMessage *)encryptMessage:(const DIMInstantMessage *)iMsg;
- (DIMInstantMessage *)decryptMessage:(const DIMSecureMessage *)sMsg;

- (DIMCertifiedMessage *)signMessage:(const DIMSecureMessage *)sMsg;
- (DIMSecureMessage *)verifyMessage:(const DIMCertifiedMessage *)cMsg;

@end

NS_ASSUME_NONNULL_END
