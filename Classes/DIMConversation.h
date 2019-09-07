//
//  DIMConversation.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/9.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

@class DIMInstantMessage;

@protocol DIMConversationDataSource;
@protocol DIMConversationDelegate;

typedef NS_ENUM(UInt8, DIMConversationID) {
    DIMConversationUnknown  = 0x00,
    DIMConversationPersonal = MKMNetwork_Main,  // 0000 1000
    DIMConversationGroup    = MKMNetwork_Group, // 0001 0000
};
typedef UInt8 DIMConversationType;

@interface DIMConversation : NSObject

@property (readonly, nonatomic) DIMConversationType type; // Network ID

@property (readonly, strong, nonatomic) DIMID *ID;
@property (readonly, strong, nonatomic) NSString *name;
@property (readonly, strong, nonatomic) NSString *title;
@property (readonly, strong, nonatomic, nullable) DIMProfile *profile;

@property (weak, nonatomic) id<DIMConversationDataSource> dataSource;
@property (weak, nonatomic) id<DIMConversationDelegate> delegate;

- (instancetype)initWithEntity:(DIMEntity *)entity
NS_DESIGNATED_INITIALIZER;

#pragma mark - Read

/**
 *  Get message count
 *
 * @return total count
 */
- (NSInteger)numberOfMessage;

/**
 *  Get message at index
 *
 * @param index - start from 0, latest first
 * @return instant message
 */
- (DIMInstantMessage *)messageAtIndex:(NSInteger)index;

/**
 *  Get last message
 *
 * @return instant message
 */
- (nullable DIMInstantMessage *)lastMessage;

#pragma mark - Write

/**
 *  Insert a new message
 *
 * @param iMsg - instant message
 */
- (BOOL)insertMessage:(DIMInstantMessage *)iMsg;

/**
 *  Delete the message
 *
 * @param iMsg - instant message
 */
- (BOOL)removeMessage:(DIMInstantMessage *)iMsg;

/**
 *  Try to withdraw the message
 *
 * @param iMsg - instant message
 */
- (BOOL)withdrawMessage:(DIMInstantMessage *)iMsg;

@end

#pragma mark - Conversation Delegates

@protocol DIMConversationDataSource <NSObject>

/**
 *  Get message count in this conversation for an entity
 *
 * @param chatBox - conversation instance
 * @return total count
 */
- (NSInteger)numberOfMessagesInConversation:(DIMConversation *)chatBox;

/**
 *  Get message at index of this conversation
 *
 * @param chatBox - conversation instance
 * @param index - start from 0, latest first
 * @return instant message
 */
- (DIMInstantMessage *)conversation:(DIMConversation *)chatBox
                     messageAtIndex:(NSInteger)index;

@end

@protocol DIMConversationDelegate <NSObject>

/**
 *  Conversation factory
 *
 * @param ID - entity ID
 * @return conversation(chat box)
 */
- (DIMConversation *)conversationWithID:(DIMID *)ID;

/**
 *  Save the new message to local storage
 *
 * @param chatBox - conversation instance
 * @param iMsg - instant message
 */
- (BOOL)conversation:(DIMConversation *)chatBox
       insertMessage:(DIMInstantMessage *)iMsg;

@optional

/**
 *  Delete the message
 *
 * @param chatBox - conversation instance
 * @param iMsg - instant message
 */
- (BOOL)conversation:(DIMConversation *)chatBox
       removeMessage:(DIMInstantMessage *)iMsg;

/**
 *  Try to withdraw the message, maybe won't success
 *
 * @param chatBox - conversation instance
 * @param iMsg - instant message
 */
- (BOOL)conversation:(DIMConversation *)chatBox
     withdrawMessage:(DIMInstantMessage *)iMsg;

@end

NS_ASSUME_NONNULL_END
