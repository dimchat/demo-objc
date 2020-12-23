//
//  LocalDatabaseManager.h
//  TimeFriend
//
//  Created by 陈均卓 on 2019/5/18.
//  Copyright © 2019 John Chen. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalDatabaseManager : NSObject

+(instancetype)sharedInstance;

-(void)createTables;

-(BOOL)insertConversation:(id<MKMID>)conversationID;
-(BOOL)updateConversation:(id<MKMID>)conversationID name:(NSString *)name image:(NSString *)imagePath lastMessage:(id<DKDInstantMessage>)msg;
-(NSMutableArray<id<MKMID>> *)loadAllConversations;
-(BOOL)clearConversation:(id<MKMID>)conversationID;
-(BOOL)deleteConversation:(id<MKMID>)conversationID;
    
-(BOOL)addMessage:(id<DKDInstantMessage>)msg toConversation:(id<MKMID>)conversationID;
-(NSMutableArray<id<DKDInstantMessage>> *)loadMessagesInConversation:(id<MKMID>)conversationID limit:(NSInteger)limit offset:(NSInteger)offset;
-(BOOL)markMessageRead:(id<MKMID>)conversationID;
-(NSInteger)getUnreadMessageCount:(nullable id<MKMID>)conversationID;

-(NSArray <id<MKMID>>*)muteListForUser:(id<MKMID>)user;
-(BOOL)isConversation:(id<MKMID>)conversation forUser:(id<MKMID>)user;

// mute
-(BOOL)muteConversation:(id<MKMID>)conversation forUser:(id<MKMID>)user;
-(BOOL)unmuteConversation:(id<MKMID>)conversation forUser:(id<MKMID>)user;
-(BOOL)unmuteAllConversationForUser:(id<MKMID>)user;

// block
-(BOOL)blockConversation:(id<MKMID>)conversation forUser:(id<MKMID>)user;
-(BOOL)unblockConversation:(id<MKMID>)conversation forUser:(id<MKMID>)user;
-(BOOL)unblockAllConversationForUser:(id<MKMID>)user;

@end

NS_ASSUME_NONNULL_END
