//
//  DIMTransceiver.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMMessageContent;
@class DIMInstantMessage;
@class DIMSecureMessage;
@class DIMCertifiedMessage;

typedef void (^DIMTransceiverCallback)(const DIMCertifiedMessage *cMsg, const NSError * _Nullable error);
typedef void (^DIMTransceiverCompletionHandler)(const NSError * _Nullable error);

@protocol DIMTransceiverDelegate <NSObject>

/**
 Send out a data package onto network

 @param data - package`
 @param handler - completion handler
 @return NO on data/delegate error
 */
- (BOOL)sendPackage:(const NSData *)data
  completionHandler:(DIMTransceiverCompletionHandler _Nullable)handler;

@end

@interface DIMTransceiver : NSObject

@property (weak, nonatomic) id<DIMTransceiverDelegate> delegate;

+ (instancetype)sharedInstance;

/**
 Pack and send message (secured + certified) to target station

 @param content - message content
 @param sender - sender ID
 @param receiver - receiver ID
 @param callback - callback function
 @return NO on data/delegate error
 */
- (BOOL)sendMessageContent:(const DIMMessageContent *)content
                      from:(const MKMID *)sender
                        to:(const MKMID *)receiver
                  callback:(DIMTransceiverCallback _Nullable)callback;

/**
 Send message (secured + certified) to target station

 @param iMsg - instant message
 @param callback - callback function
 @return NO on data/delegate error
 */
- (BOOL)sendMessage:(const DIMInstantMessage *)iMsg
           callback:(DIMTransceiverCallback _Nullable)callback;

/**
 Retrieve message from the received package

 @param data - received package
 @return InstantMessage
 */
- (DIMInstantMessage *)messageFromReceivedPackage:(const NSData *)data;

#pragma mark -

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
 Pack instant message to deliver it

 @param iMsg - instant message
 @return CertifiedMessage Object
 */
- (DIMCertifiedMessage *)encryptAndSignMessage:(const DIMInstantMessage *)iMsg;

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
