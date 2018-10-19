//
//  DIMConversation.h
//  DIM
//
//  Created by Albert Moky on 2018/10/9.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

NS_ENUM(UInt8) {
    DIMConversationPersonal = MKMNetwork_Main,  // 0000 1000
    DIMConversationGroup    = MKMNetwork_Group, // 0001 0000
};
typedef MKMNetworkID DIMConversationType;

@protocol DIMConversationDelegate;

@interface DIMConversation : NSObject {
    
    // the latest message is in the first
    NSMutableArray<const DIMInstantMessage *> *_messages;
}

@property (readonly, nonatomic) DIMConversationType type;

@property (readonly, strong, nonatomic) MKMID *ID;
@property (readonly, strong, nonatomic) NSString *title;

@property (weak, nonatomic) id<DIMConversationDelegate> delegate;

- (instancetype)initWithEntity:(const MKMEntity *)entity
NS_DESIGNATED_INITIALIZER;

/**
 Insert an instant message into the list

 @param iMsg - instant message
 @return message position in the list, -1 on error
 */
- (NSInteger)insertInstantMessage:(const DIMInstantMessage *)iMsg;

- (NSArray *)messagesWithRange:(NSRange)range;

@end

#pragma mark - Conversation Delegate

@protocol DIMConversationDelegate <NSObject>

/**
 Save new message
 
 @param chatroom - conversation
 @param iMsg - instant message
 */
- (void)conversation:(const DIMConversation *)chatroom
   didReceiveMessage:(const DIMInstantMessage *)iMsg;

/**
 Get messages
 
 @param chatroom - conversation
 @param time - looking back from that time (excludes)
 @param count - max count (default is 10)
 @return messages
 */
- (NSArray *)conversation:(const DIMConversation *)chatroom
           messagesBefore:(const NSDate *)time
                 maxCount:(NSUInteger)count;

@end

#pragma mark - Conversations Pool

@interface DIMConversationManager : NSObject

@property (weak, nonatomic) id<DIMConversationDelegate> delegate;

+ (instancetype)sharedInstance;

- (DIMConversation *)conversationWithID:(const MKMID *)ID;

- (void)setConversation:(DIMConversation *)chatroom;

@end

NS_ASSUME_NONNULL_END
