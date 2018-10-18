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
    }
    return self;
}

#pragma mark - Users

- (void)setCurrentUser:(DIMUser *)currentUser {
    if (![_currentUser.ID isEqual:currentUser.ID]) {
        _currentUser = currentUser;
        // add to list
        [self addUser:currentUser];
    }
}

- (void)addUser:(DIMUser *)user {
    if ([_users containsObject:user]) {
        // already exists
        return ;
    } else {
        [_users addObject:user];
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

- (void)setCurrentConnection:(DIMConnection *)currentConnection {
    if (![_currentConnection isEqual:currentConnection]) {
        [_currentConnection disconnect];
        
        _currentConnection = currentConnection;
    }
}

- (BOOL)connect:(const DIMStation *)station {
    DIMConnection *conn = [[DIMConnection alloc] initWithTargetStation:station];
    if ([conn connect]) {
        self.currentConnection = conn;
        return YES;
    } else {
        NSLog(@"connect failed");
        return NO;
    }
}

- (BOOL)reconnect {
    if (_currentConnection.isConnected) {
        NSLog(@"already connected");
        return YES;
    }
    return [_currentConnection connect];
}

- (void)disconnect {
    [_currentConnection disconnect];
}

#pragma mark - DIMConnectionDelegate

- (void)connection:(const DIMConnection *)conn didReceiveData:(NSData *)data {
    NSLog(@"received data from %@ ...", conn.target.host);
    
    NSString *json = [data jsonString];
    
    DIMCertifiedMessage *cMsg;
    cMsg = [[DIMCertifiedMessage alloc] initWithJSONString:json];
    
    [self saveMessage:cMsg];
}

@end

#pragma mark - Message

@implementation DIMClient (Message)

- (BOOL)sendMessage:(const DIMCertifiedMessage *)message {
    if (_currentConnection.isConnected != YES) {
        NSLog(@"connect first");
        return NO;
    }
    MKMID *sender = message.envelope.sender;
    NSAssert(sender.address.network == MKMNetwork_Main, @"error");
    NSAssert(message.signature, @"signature cannot be empty");
    
    NSData *jsonData = [message jsonData];
    return [_currentConnection sendData:jsonData];
}

- (void)saveMessage:(const DIMCertifiedMessage *)message {
    NSLog(@"saving message: %@", message);
    
    // TODO: process message
}

@end
