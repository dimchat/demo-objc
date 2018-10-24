//
//  DIMConversationDelegate.h
//  DIM
//
//  Created by Albert Moky on 2018/10/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DIMConversation;
@class DIMInstantMessage;
@class DIMCertifiedMessage;

@protocol DIMConversationDelegate <NSObject>

/**
 Send a certified secure message onto the network

 @param chatroom - conversation instance
 @param cMsg - certified secure message
 */
- (void)conversation:(const DIMConversation *)chatroom
         sendMessage:(const DIMCertifiedMessage *)cMsg;

/**
 Save the new message
 
 @param chatroom - conversation instance
 @param iMsg - instant message
 */
- (void)conversation:(const DIMConversation *)chatroom
   didReceiveMessage:(const DIMInstantMessage *)iMsg;

@optional

/**
 Send message success

 @param chatroom - conversation instance
 @param cMsg - certified secure message
 */
- (void)conversation:(const DIMConversation *)chatroom didSendMessage:(const DIMCertifiedMessage *)cMsg;

/**
 Failed to send message

 @param chatroom - conversation instance
 @param error - reason
 */
- (void)conversation:(const DIMConversation *)chatroom didFailWithError:(const NSError *)error;

/**
 Delete the message

 @param chatroom - conversation instance
 @param iMsg - instant message
 */
- (void)conversation:(const DIMConversation *)chatroom
       removeMessage:(const DIMInstantMessage *)iMsg;
/**
 Try to withdraw the message, maybe won't success

 @param chatroom - conversation instance
 @param iMsg - instant message
 */
- (void)conversation:(const DIMConversation *)chatroom
     withdrawMessage:(const DIMInstantMessage *)iMsg;

@end

NS_ASSUME_NONNULL_END
