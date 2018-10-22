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
#import "DIMConnector.h"

#import "DIMClient+Message.h"
#import "DIMClient.h"

@interface DIMClient () {
    
    NSMutableArray<DIMUser *> *_users;
}

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
        _currentUser = nil;
        _currentConnection = nil;
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

#pragma mark - Connection

- (void)setCurrentConnection:(DIMConnection *)newConnection {
    if ([_currentConnection isEqual:newConnection]) {
        return;
    }
    
    // 1. close the current connection
    if (_currentConnection.isConnected) {
        NSAssert(_connector, @"connector not set");
        [_connector closeConnection:_currentConnection];
    }
    
    // 2. check the connection delegate
    if (newConnection.delegate == nil) {
        newConnection.delegate = self;
    }
    
    // 3. replace current connection
    _currentConnection = newConnection;
}

- (BOOL)connectTo:(const DIMStation *)station {
    NSAssert(station.host, @"station.host cannot be empty");
    NSAssert(_connector, @"set connector first");
    self.currentConnection = nil;
    DIMConnection *conn = [_connector connectTo:station];
    self.currentConnection = conn;
    return conn.isConnected;
}

- (BOOL)reconnect {
    if (_currentConnection.isConnected) {
        return YES;
    }
    DIMStation *server = _currentConnection.target;
    NSAssert(server, @"error");
    return [self connectTo:server];
}

- (void)disconnect {
    NSAssert(_currentConnection, @"current connection not set");
    NSAssert(_connector, @"connector not set");
    [_connector closeConnection:_currentConnection];
}

#pragma mark - DIMConnectionDelegate

- (void)connection:(const DIMConnection *)conn didReceiveData:(const NSData *)data {
    NSLog(@"received data from %@ ...", conn.target.host);
    
    NSDictionary *dict = [data jsonDictionary];
    
    // Check: system command
    NSDictionary *syscmd = [dict objectForKey:@"command"];
    if (syscmd) {
        NSLog(@"received a command: %@", syscmd);
        // TODO: execute the command
        
        return;
    }
    
    DIMTransceiver *trans = [[DIMTransceiver alloc] init];
    DIMCertifiedMessage *cMsg;
    DIMInstantMessage *iMsg;
    
    // verify & decrypt the receive data
    cMsg = [[DIMCertifiedMessage alloc] initWithDictionary:dict];
    NSAssert(cMsg.signature, @"data error: %@", dict);
    
    iMsg = [trans verifyAndDecryptMessage:cMsg];
    NSAssert(iMsg.content, @"message error: %@", cMsg);
    
    // Check: top-secret message
    if (iMsg.content.type == DIMMessageType_Forward) {
        // do it again to drop the wrapper,
        // the secret inside the content is the real message
        cMsg = iMsg.content.secretMessage;
        NSAssert(cMsg.signature, @"data error: %@", dict);
        
        iMsg = [trans verifyAndDecryptMessage:cMsg];
        NSAssert(iMsg.content, @"message error: %@", cMsg);
    }
    
    [self recvMessage:iMsg];
}

- (void)connection:(const DIMConnection *)conn didSendData:(const NSData *)data {
    NSLog(@"data sent");
    // TODO: remove the data from message queue out
}

- (void)connection:(const DIMConnection *)conn didFailWithError:(const NSError *)error {
    NSLog(@"connection failed: %@", error);
    // TODO: try to send again or mark failed
}

@end
