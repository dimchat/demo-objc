//
//  DIMMessageTable.m
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMFacebook.h"
#import "LocalDatabaseManager.h"
#import "DIMMessageTable.h"

typedef NSMutableDictionary<DIMID *, NSArray *> CacheTableM;

@interface DIMMessageTable () {
    
    CacheTableM *_caches;
    
    NSMutableArray<DIMID *> *_conversations;
}

@end

@implementation DIMMessageTable

- (instancetype)init {
    if (self = [super init]) {
        _caches = [[CacheTableM alloc] init];
        _conversations = nil;
    }
    return self;
}

- (NSMutableArray<DIMID *> *)allConversations {
    
    if(_conversations == nil || _conversations.count == 0){
        _conversations = [[LocalDatabaseManager sharedInstance] loadAllConversations];
    }
    
    return _conversations;
    
//    if (_conversations) {
//        return _conversations;
//    }
//    _conversations = [[NSMutableArray alloc] init];
//
//    NSString *dir = [self _baseDir];
//
//    NSFileManager *fm = [NSFileManager defaultManager];
//    NSDirectoryEnumerator *de = [fm enumeratorAtPath:dir];
//
//    DIMID *ID;
//    DIMAddress *address;
//    NSString *string;
//
//    NSString *path;
//    while (path = [de nextObject]) {
//        if (![path hasSuffix:@"/messages.plist"]) {
//            // no messages
//            continue;
//        }
//        string = [path substringToIndex:(path.length - 15)];
//        address = MKMAddressFromString(string);
////        if (MKMNetwork_IsStation(address.network)) {
////            // ignore station history
////            continue;
////        }
//
//        ID = DIMIDWithAddress(address);
//        if ([ID isValid]) {
//            NSLog(@"ID: %@", ID);
//            [_conversations addObject:ID];
//        } else {
//            NSLog(@"failed to load message in path: %@", path);
//        }
//    }
//
//    return _conversations;
}

- (void)_updateCache:(NSArray *)messages conversation:(DIMID *)ID {
    NSMutableArray *list = (NSMutableArray *)[self allConversations];
    
    if (messages) {
        // update cache
        [_caches setObject:messages forKey:ID];
        // add cid
        if (![list containsObject:ID]) {
            [list addObject:ID];
        }
    } else {
        // erase cache
        [_caches removeObjectForKey:ID];
        // remove cid
        [list removeObject:ID];
    }
}

/**
 *  Get messages filepath in Documents Directory
 *
 * @param ID - group ID
 * @return "Documents/.dim/{address}/messages.plist"
 */
- (NSString *)_filePathWithID:(DIMID *)ID {
    NSString *dir = self.documentDirectory;
    dir = [dir stringByAppendingPathComponent:@".dim"];
    dir = [dir stringByAppendingPathComponent:ID.address];
    return [dir stringByAppendingPathComponent:@"messages.plist"];
}

- (nullable NSArray<DIMInstantMessage *> *)_loadMessages:(DIMID *)ID {
    
    return [[LocalDatabaseManager sharedInstance] loadMessagesInConversation:ID limit:-1 offset:-1];
    
//    NSString *path = [self _filePathWithID:ID];
//    NSArray *array = [self arrayWithContentsOfFile:path];
//    if (!array) {
//        NSLog(@"messages not found: %@", path);
//        return nil;
//    }
//    NSLog(@"messages from %@", path);
//    NSMutableArray<DIMInstantMessage *> *messages;
//    DIMInstantMessage *msg;
//    messages = [[NSMutableArray alloc] initWithCapacity:array.count];
//    for (NSDictionary *item in array) {
//        msg = DKDInstantMessageFromDictionary(item);
//        if (!msg) {
//            NSAssert(false, @"message invalid: %@", item);
//            continue;
//        }
//        [messages addObject:msg];
//    }
//    return messages;
}

- (NSArray<DIMInstantMessage *> *)messagesInConversation:(DIMID *)ID {
    NSArray<DIMInstantMessage *> *messages = [_caches objectForKey:ID];
    if (!messages) {
        messages = [self _loadMessages:ID];
        [self _updateCache:messages conversation:ID];
    }
    return messages;
}

- (BOOL)addMessage:(DIMInstantMessage *)message toConversation:(DIMID *)ID{
    
    BOOL insertSuccess = [[LocalDatabaseManager sharedInstance] addMessage:message toConversation:ID];
    
    if(insertSuccess){
        //Update cache
        NSMutableArray *currentMessages = [[NSMutableArray alloc] initWithArray:[_caches objectForKey:ID]];
        [currentMessages addObject:message];
        [self _updateCache:currentMessages conversation:ID];
    }
    
    return insertSuccess;
}

- (BOOL)clearConversation:(DIMID *)ID{
    [self _updateCache:[NSArray array] conversation:ID];
    return [[LocalDatabaseManager sharedInstance] clearConversation:ID];
}

- (BOOL)saveMessages:(NSArray<DIMInstantMessage *> *)list conversation:(DIMID *)ID {
    // update cache
    [self _updateCache:list conversation:ID];
    // update storage
    NSString *path = [self _filePathWithID:ID];
    if (list) {
        // update conversation
        NSLog(@"saving messages into: %@", path);
        return [self array:list writeToFile:path];
    } else {
        // remove conversation
        NSLog(@"removing conversation from: %@", path);
        return [self removeItemAtPath:path];
    }
}

- (BOOL)removeConversation:(DIMID *)ID {
    return [[LocalDatabaseManager sharedInstance] deleteConversation:ID];
    
//    NSString *path = [self _filePathWithID:ID];
//    NSLog(@"removing conversation: %@", path);
//    return [self removeItemAtPath:path];
}

@end
