//
//  DIMConversation.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/9.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMConversation;
@class DIMInstantMessage;
@class DIMCertifiedMessage;

@protocol DIMConversationDataSource <NSObject>

/**
 Get message count in this conversation for an entity
 
 @param chatroom - conversation instance
 @return total count
 */
- (NSInteger)numberOfMessagesInConversation:(const DIMConversation *)chatroom;

/**
 Get message at index of this conversation
 
 @param chatroom - conversation instance
 @param index - start from 0, latest first
 @return instant message
 */
- (DIMInstantMessage *)conversation:(const DIMConversation *)chatroom
                     messageAtIndex:(NSInteger)index;

@optional
/**
 Get messages before a time
 
 @param chatroom - conversation instance
 @param time - looking back from that time (excludes)
 @param count - max count (default is 10)
 @return messages
 */
- (NSArray *)conversation:(const DIMConversation *)chatroom
           messagesBefore:(const NSDate *)time
                 maxCount:(NSUInteger)count;

@end

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
- (void)conversation:(const DIMConversation *)chatroom
      didSendMessage:(const DIMCertifiedMessage *)cMsg;

/**
 Failed to send message
 
 @param chatroom - conversation instance
 @param error - reason
 */
- (void)conversation:(const DIMConversation *)chatroom
    didFailWithError:(const NSError *)error;

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

#pragma mark -

typedef NS_ENUM(UInt8, DIMConversationID) {
    DIMConversationPersonal = MKMNetwork_Main,  // 0000 1000
    DIMConversationGroup    = MKMNetwork_Group, // 0001 0000
};
typedef UInt8 DIMConversationType;

@protocol DIMConversationDataSource;
@protocol DIMConversationDelegate;

@interface DIMConversation : NSObject

@property (readonly, nonatomic) DIMConversationType type; // Network ID

@property (readonly, strong, nonatomic) MKMID *ID;
@property (readonly, strong, nonatomic) NSString *title;

@property (weak, nonatomic) id<DIMConversationDataSource> dataSource;
@property (weak, nonatomic) id<DIMConversationDelegate> delegate;

- (instancetype)initWithEntity:(const MKMEntity *)entity
NS_DESIGNATED_INITIALIZER;

#pragma mark - Read

/**
 Get message count

 @return total count
 */
- (NSInteger)numberOfMessage;

/**
 Get message at index

 @param index - start from 0, latest first
 @return instant message
 */
- (DIMInstantMessage *)messageAtIndex:(NSInteger)index;

#pragma mark - Write

- (void)insertMessage:(const DIMInstantMessage *)iMsg;

/**
 Delete the message

 @param iMsg - instant message
 */
- (void)removeMessage:(const DIMInstantMessage *)iMsg;

/**
 Try to withdraw the message

 @param iMsg - instant message
 */
- (void)withdrawMessage:(const DIMInstantMessage *)iMsg;

@end

NS_ASSUME_NONNULL_END
