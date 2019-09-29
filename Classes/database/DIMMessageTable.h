//
//  DIMMessageTable.h
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMMessageTable : DIMStorage

- (NSArray<DIMID *> *)allConversations;

- (BOOL)removeConversation:(DIMID *)ID;

#pragma mark -

- (NSArray<DIMInstantMessage *> *)messagesInConversation:(DIMID *)ID;

- (BOOL)saveMessages:(NSArray<DIMInstantMessage *> *)list conversation:(DIMID *)ID;
- (BOOL)addMessage:(DIMInstantMessage *)message toConversation:(DIMID *)ID;
- (BOOL)clearConversation:(DIMID *)ID;

@end

NS_ASSUME_NONNULL_END
