//
//  DKDTransceiver.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

@class DKDMessageContent;
@class DKDInstantMessage;
@class DKDSecureMessage;
@class DKDReliableMessage;

typedef void (^DKDTransceiverCallback)(const DKDReliableMessage *rMsg, const NSError * _Nullable error);
typedef void (^DKDTransceiverCompletionHandler)(const NSError * _Nullable error);

@protocol DKDTransceiverDelegate <NSObject>

/**
 Send out a data package onto network

 @param data - package`
 @param handler - completion handler
 @return NO on data/delegate error
 */
- (BOOL)sendPackage:(const NSData *)data
  completionHandler:(nullable DKDTransceiverCompletionHandler)handler;

@end

@interface DKDTransceiver : NSObject

@property (weak, nonatomic) id<DKDTransceiverDelegate> delegate;

+ (instancetype)sharedInstance;

/**
 Pack and send message (secured + certified) to target station

 @param content - message content
 @param sender - sender ID
 @param receiver - receiver ID
 @param callback - callback function
 @return NO on data/delegate error
 */
- (BOOL)sendMessageContent:(const DKDMessageContent *)content
                      from:(const MKMID *)sender
                        to:(const MKMID *)receiver
                      time:(nullable const NSDate *)time
                  callback:(nullable DKDTransceiverCallback)callback;

/**
 Send message (secured + certified) to target station

 @param iMsg - instant message
 @param callback - callback function
 @return NO on data/delegate error
 */
- (BOOL)sendMessage:(const DKDInstantMessage *)iMsg
           callback:(nullable DKDTransceiverCallback)callback;

/**
 Retrieve message from the received package

 @param data - received package
 @return InstantMessage
 */
- (DKDInstantMessage *)messageFromReceivedPackage:(const NSData *)data;

#pragma mark -

/**
 Pack message content with sender and receiver to deliver it

 @param content - message content
 @param sender - sender ID
 @param receiver - receiver ID
 @return ReliableMessage Object
 */
- (DKDReliableMessage *)encryptAndSignContent:(const DKDMessageContent *)content
                                       sender:(const MKMID *)sender
                                     receiver:(const MKMID *)receiver
                                         time:(nullable const NSDate *)time;

/**
 Pack instant message to deliver it

 @param iMsg - instant message
 @return ReliableMessage Object
 */
- (DKDReliableMessage *)encryptAndSignMessage:(const DKDInstantMessage *)iMsg;

/**
 Extract instant message from a reliable message

 @param rMsg - reliable message
 @return InstantMessage object
 */
- (DKDInstantMessage *)verifyAndDecryptMessage:(const DKDReliableMessage *)rMsg;

@end

NS_ASSUME_NONNULL_END
