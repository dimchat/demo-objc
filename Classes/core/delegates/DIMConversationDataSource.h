//
//  DIMConversationDataSource.h
//  DIM
//
//  Created by Albert Moky on 2018/10/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DIMConversation;
@class DIMInstantMessage;

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

NS_ASSUME_NONNULL_END
