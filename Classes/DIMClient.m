//
//  DIMClient.m
//  DIM
//
//  Created by Albert Moky on 2018/10/16.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMEnvelope.h"
#import "DIMCertifiedMessage.h"

#import "DIMStation.h"
#import "DIMConnection.h"

#import "DIMBarrack.h"

#import "DIMClient.h"

@interface DIMClient () {
    
    NSMutableArray<DIMUser *> *_users;
}

@property (strong, nonatomic) DIMConnection *connection;

@end

@implementation DIMClient

static DIMClient *s_sharedInstance = nil;

+ (instancetype)sharedInstance {
    if (!s_sharedInstance) {
        s_sharedInstance = [[self alloc] init];
    }
    return s_sharedInstance;
}

+ (instancetype)alloc {
    NSAssert(!s_sharedInstance, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        _users = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Users

- (void)setCurrentUser:(DIMUser *)currentUser {
    if (![_currentUser isEqual:currentUser]) {
        _currentUser = currentUser;
        // add to list
        if (currentUser && ![_users containsObject:currentUser]) {
            [_users addObject:currentUser];
        }
    }
}

- (void)addUser:(DIMUser *)user {
    if (user && ![_users containsObject:user]) {
        [_users addObject:user];
    }
    // check current user
    if (!_currentUser) {
        _currentUser = user;
    }
}

- (void)removeUser:(DIMUser *)user {
    if ([_users containsObject:user]) {
        [_users removeObject:user];
    }
    // check current user
    if ([_currentUser isEqual:user]) {
        _currentUser = _users.firstObject;
    }
}

#pragma mark - Station Connection

- (void)setConnection:(DIMConnection *)connection {
    if (![_connection isEqual:connection]) {
        // disconnect the old connection
        if (_connection.isConnected) {
            NSAssert(_connector, @"connector cannot be empty");
            [_connector closeConnection:_connection];
        }
        
        // check connection delegate
        if (connection.delegate == nil) {
            connection.delegate = self;
        }
        // replace with the new connection
        _connection = connection;
    }
}

- (void)disconnect {
    self.connection = nil;
}

- (BOOL)connect:(const DIMStation *)station {
    NSAssert(_connector, @"connector cannot be empty");
    NSAssert(station.host, @"station.host cannot be empty");
    self.connection = [_connector connectToStation:station client:self];
    NSAssert(_connection.isConnected, @"connect failed");
    return _connection.isConnected;
}

#pragma mark - DIMConnectionDelegate

- (void)connection:(const DIMConnection *)conn didReceiveData:(NSData *)data {
    NSLog(@"received data from %@ ...", conn.target.host);
    
    DIMTransceiver *trans = [[DIMTransceiver alloc] init];
    
    NSString *json = [data jsonString];
    
    DIMCertifiedMessage *cMsg;
    cMsg = [[DIMCertifiedMessage alloc] initWithJSONString:json];
    NSAssert(cMsg.signature, @"data error: %@", json);
    
    DIMInstantMessage *iMsg;
    iMsg = [trans verifyAndDecryptMessage:cMsg];
    NSAssert(iMsg.content, @"message error: %@", cMsg);
    
    [self recvMessage:iMsg];
}

- (void)connection:(const DIMConnection *)conn didSendData:(NSData *)data {
    NSLog(@"data sent");
    // TODO: remove the data from message queue out
}

- (void)connection:(const DIMConnection *)conn didFailWithError:(NSError *)error {
    NSLog(@"connection failed: %@", error);
    // TODO: try to send again or mark failed
}

@end

#pragma mark - Message

@implementation DIMClient (Message)

- (BOOL)sendMessage:(const DIMCertifiedMessage *)cMsg {
    if (_connection.isConnected != YES) {
        NSLog(@"connect first");
        return NO;
    }
    MKMID *sender = cMsg.envelope.sender;
    NSAssert(sender.address.network == MKMNetwork_Main, @"error");
    NSAssert(cMsg.signature, @"signature cannot be empty");
    
    NSData *jsonData = [cMsg jsonData];
    return [_connection sendData:jsonData];
}

- (void)recvMessage:(const DIMInstantMessage *)iMsg {
    NSLog(@"saving message: %@", iMsg);
    
    DIMBarrack *barrack = [DIMBarrack sharedInstance];
    
    DIMConversationManager *chatman = [DIMConversationManager sharedInstance];
    DIMConversation *chatroom;
    
    DIMEnvelope *env = iMsg.envelope;
    MKMID *sender = env.sender;
    MKMID *receiver = env.receiver;
    
    if ([receiver isEqual:_currentUser.ID]) {
        // personal chat, get chatroom with contact ID
        chatroom = [chatman conversationWithID:sender];
        if (!chatroom) {
            DIMContact *contact = [barrack contactForID:sender];
            chatroom = [[DIMConversation alloc] initWithEntity:contact];
            [chatman setConversation:chatroom];
        }
    } else if (receiver.address.network == MKMNetwork_Group) {
        // group chat, get chatroom with group ID
        chatroom = [chatman conversationWithID:receiver];
        if (!chatroom) {
            DIMGroup *group = [barrack groupForID:receiver];
            chatroom = [[DIMConversation alloc] initWithEntity:group];
            [chatman setConversation:chatroom];
        }
    }
    NSAssert(chatroom, @"chat room not found");
    
    [chatroom insertInstantMessage:iMsg];
}

@end
