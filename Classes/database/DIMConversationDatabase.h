//
//  DIMConversationDatabase.h
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMConversation.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const DIMConversationUpdatedNotification;

@protocol DIMConversationDatabase <DIMConversationDataSource, DIMConversationDelegate>

- (NSArray<DIMConversation *> *)allConversations;
- (BOOL)removeConversation:(DIMConversation *)chatBox;
- (BOOL)clearConversation:(DIMConversation *)chatBox;
- (NSArray<DIMInstantMessage *> *)messagesInConversation:(DIMConversation *)chatBox;

-(BOOL)markConversationMessageRead:(DIMConversation *)chatBox;

@end

@interface DIMConversationDatabase : NSObject <DIMConversationDatabase>

@end

@interface DIMConversationDatabase (GroupCommand)

- (BOOL)processGroupCommand:(DIMGroupCommand *)cmd
                  commander:(DIMID *)sender;

// query
- (BOOL)processQueryCommand:(DIMGroupCommand *)gCmd
                  commander:(DIMID *)sender
                  polylogue:(DIMPolylogue *)group;

@end

NS_ASSUME_NONNULL_END
