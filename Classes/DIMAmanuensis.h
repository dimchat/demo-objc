//
//  DIMAmanuensis.h
//  DIMC
//
//  Created by Albert Moky on 2018/10/21.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCore.h"

NS_ASSUME_NONNULL_BEGIN

#define DIMConversationWithID(ID) [[DIMAmanuensis sharedInstance] conversationWithID:(ID)]

/**
 *  Conversation pool to manage chatroom instances
 *
 *      1st, get instance here to avoid create same instance,
 *      2nd, if their history was updated, we can notice them here immediately
 */
@interface DIMAmanuensis : NSObject

@property (weak, nonatomic) id<DIMConversationDataSource> dataSource;
@property (weak, nonatomic) id<DIMConversationDelegate> delegate;

+ (instancetype)sharedInstance;

// conversation
- (DIMConversation *)conversationWithID:(const MKMID *)ID;
- (void)setConversation:(DIMConversation *)chatroom;
- (void)removeConversation:(DIMConversation *)chatroom;

@end

NS_ASSUME_NONNULL_END
