//
//  LocalDatabaseManager.m
//  TimeFriend
//
//  Created by 陈均卓 on 2019/5/18.
//  Copyright © 2019 John Chen. All rights reserved.
//

#import "LocalDatabaseManager.h"
#import "FolderUtility.h"
#import "FMDB.h"
#import "NSObject+JsON.h"
#import "DKDInstantMessage+Extension.h"
#import "DIMFacebook.h"
#import <sqlite3.h>

@interface LocalDatabaseManager()

@property(nonatomic, strong) FMDatabase *db;

@end

@implementation LocalDatabaseManager

+ (instancetype)sharedInstance {
    
    static LocalDatabaseManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(void)dealloc{
    
    
}

-(id)init{
    
    if(self = [super init]){
        
        NSString *documentPath = [[FolderUtility sharedInstance] applicationDocumentsDirectory];
        documentPath = [documentPath stringByAppendingPathComponent:@".dim"];
        
        [[FolderUtility sharedInstance] createFolder:documentPath];
        
        NSString *path = [documentPath stringByAppendingPathComponent:@"sechat.db"];
        NSLog(@"The database path is : %@", path);
        self.db = [FMDatabase databaseWithPath:path];
        self.db.logsErrors = NO;
        [self.db openWithFlags:SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE|SQLITE_OPEN_FULLMUTEX];
        
        [self createTables];
    }
    
    return self;
}

-(void)createTables{
    
    NSString *sql = @"CREATE TABLE IF NOT EXISTS messages (conversation_id text, sn integer, type integer, msg_text text, content text, sender text, receiver text, time REAL, status integer, PRIMARY KEY(conversation_id, sn));";
    BOOL success = [self.db executeStatements:sql];
    
    if(!success){
        NSLog(@"Can not create messages table");
    }
    
    sql = @"CREATE TABLE IF NOT EXISTS conversation (conversation_id text primary key, name text, image text, last_message text, last_time REAL);";
    success = [self.db executeStatements:sql];
    
    if(!success){
        NSLog(@"Can not create conversation table");
    }
}

-(BOOL)insertConversation:(DIMID *)conversationID{
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO conversation (conversation_id, name, image, last_message, last_time) VALUES ('%@', '', '', '', 0);", conversationID];
    BOOL success = [self.db executeStatements:sql];
    return success;
}

-(BOOL)clearConversation:(DIMID *)conversationID{
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM messages WHERE conversation_id='%@';", conversationID];
    BOOL success = [self.db executeStatements:sql];
    return success;
}

-(BOOL)deleteConversation:(DIMID *)conversationID{
    
    [self clearConversation:conversationID];
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM conversation WHERE conversation_id='%@';", conversationID];
    BOOL success = [self.db executeStatements:sql];
    return success;
}

-(BOOL)updateConversation:(DIMID *)conversationID name:(NSString *)name image:(NSString *)imagePath lastMessage:(DIMInstantMessage *)msg{
    
    NSTimeInterval lastTime = [msg.envelope.time timeIntervalSince1970];
    NSString *lastMessage = [msg.content objectForKey:@"text"];
    
    NSString *sql = @"UPDATE conversation SET";
    
    if(name != nil){
        sql = [NSString stringWithFormat:@"%@ name='%@', ", sql, name];
    }
    
    if(imagePath != nil){
        sql = [NSString stringWithFormat:@"%@ image='%@', ", sql, imagePath];
    }
    
    sql = [NSString stringWithFormat:@"%@ last_message='%@', last_time=%.3f", sql, lastMessage, lastTime];
    
    BOOL success = [self.db executeStatements:sql];
    if(!success){
        NSLog(@"Can not update conversation : %@", self.db.lastError.localizedDescription);
    }
    return success;
}

-(BOOL)addMessage:(DIMInstantMessage *)msg toConversation:(DIMID *)conversationID{
    
    [self insertConversation:conversationID];
    
    NSString *content_text = [msg.content jsonString];
    NSTimeInterval sendTime = [msg.envelope.time timeIntervalSince1970];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO messages (conversation_id, sn, type, msg_text, content, sender, receiver, time, status) VALUES ('%@', %lu, %d, '%@', '%@', '%@', '%@', %.3f, %d);", conversationID, msg.content.serialNumber, msg.content.type, [msg.content objectForKey:@"text"], content_text, msg.envelope.sender, msg.envelope.receiver, sendTime, msg.state];
    BOOL success = [self.db executeStatements:sql];
    
    if(success){
        
        //Update conversation last message
        [self updateConversation:conversationID name:@"" image:@"" lastMessage:msg];
        
    }else{
        NSLog(@"Can not insert message : %@ %@", self.db.lastError.localizedDescription, content_text);
    }
    
    return success;
}

-(NSMutableArray<DIMID *> *)loadAllConversations{
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSString *sql = @"SELECT * FROM conversation where last_time > 0";
    FMResultSet *s = [self.db executeQuery:sql];
    while ([s next]) {
        
        NSString *IDString = [s stringForColumnIndex:0];
        DIMID *ID = DIMIDWithString(IDString);
        [array addObject:ID];
    }
    return array;
}

-(NSMutableArray<DIMInstantMessage *> *)loadMessagesInConversation:(DIMID *)conversationID limit:(NSInteger)limit offset:(NSInteger)offset{
    
    NSMutableArray<DIMInstantMessage *> *messages = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM messages WHERE conversation_id='%@' ORDER BY time", conversationID];
    FMResultSet *s = [self.db executeQuery:sql];
    
    while ([s next]) {
        
        NSString *content_text = [s stringForColumn:@"content"];
        NSString *sender = [s stringForColumn:@"sender"];
        NSString *receiver = [s stringForColumn:@"receiver"];
        NSInteger time = [s doubleForColumn:@"time"];
        NSInteger status = [s intForColumn:@"status"];
        
        NSDictionary *contentDict = [[content_text data] jsonDictionary];
        NSDictionary *messageDict = @{
            @"content": contentDict,
            @"sender": sender,
            @"receiver": receiver,
            @"time": [NSNumber numberWithInteger:time],
            @"status": [NSNumber numberWithInteger:status]
        };
        
        DIMInstantMessage *msg = DKDInstantMessageFromDictionary(messageDict);
        if (!msg) {
            NSAssert(false, @"message invalid: %@", messageDict);
            continue;
        }
        
        [messages addObject:msg];
    }
    
    return messages;
}

-(BOOL)markMessageRead:(DIMID *)conversationID{
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE messages SET status=%d WHERE conversation_id='%@'", DIMMessageState_Read, conversationID];
    
    BOOL success = [self.db executeStatements:sql];
    if(!success){
        NSLog(@"Can not update conversation : %@", self.db.lastError.localizedDescription);
    }
    return success;
}

-(NSInteger)getUnreadMessageCount:(nullable DIMID *)conversationID{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) AS mc FROM messages WHERE status!=%d AND type IN (1, 16, 18, 20, 22)", DIMMessageState_Read];
    
    if(conversationID != nil){
        sql = [NSString stringWithFormat:@"%@ AND conversation_id='%@'", sql, conversationID];
    }
    
    NSLog(@"%@", sql);
    
    FMResultSet *s = [self.db executeQuery:sql];
    
    NSInteger count = 0;
    if([s next]){
        count = [s intForColumn:@"mc"];
    }
    
    return count;
}

@end
