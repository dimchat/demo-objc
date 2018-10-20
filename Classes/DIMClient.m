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
    [_currentConnection close];
    
    // 2. check the connection delegate
    if (newConnection.delegate == nil) {
        newConnection.delegate = self;
    }
    
    // 3. replace current connection
    _currentConnection = newConnection;
}

- (BOOL)connect:(DIMStation *)station {
    if (!_currentConnection) {
        NSAssert(false, @"current connection cannot be empty");
        return NO;
    }
    NSAssert(station.host, @"station.host cannot be empty");
    return [_currentConnection connectTo:station];
}

- (void)disconnect {
    NSAssert(_currentConnection, @"current connection not set");
    [_currentConnection close];
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
