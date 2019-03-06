//
//  DIMTerminal.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MarsGate/MarsGate.h>

#import "NSObject+JsON.h"

#import "DIMServer.h"
#import "DIMTerminal+Request.h"
#import "DIMTerminal+Response.h"

#import "DIMTerminal.h"

@interface DIMTerminal ()

@property (strong, nonatomic) NSMutableArray<DIMUser *> *users;

@end

@implementation DIMTerminal

- (instancetype)init {
    if (self = [super init]) {
        _users = [[NSMutableArray alloc] init];
        
        _currentStation = nil;
        _session = nil;
    }
    return self;
}

- (NSString *)userAgent {
    return @"DIMP/1.0 (iPad; U; iOS 11.4; zh-CN) DIMCoreKit/1.0 (Terminal, like WeChat) DIM-by-GSP/1.0.1";
}

#pragma mark - User(s)

- (DIMUser *)currentUser {
    return _currentStation.currentUser;
}

- (void)setCurrentUser:(DIMUser *)user {
    _currentStation.currentUser = user;
    if (user && ![_users containsObject:user]) {
        // insert the user to the first
        [_users insertObject:user atIndex:0];
    }
}

- (void)addUser:(DIMUser *)user {
    if (user && ![_users containsObject:user]) {
        [_users addObject:user];
    }
    // check current user
    if (!_currentStation.currentUser) {
        _currentStation.currentUser = user;
    }
}

- (void)removeUser:(DIMUser *)user {
    if ([_users containsObject:user]) {
        [_users removeObject:user];
    }
    // check current user
    if ([_currentStation.currentUser isEqual:user]) {
        _currentStation.currentUser = _users.firstObject;
    }
}

#pragma mark DIMStationDelegate

- (void)station:(nonnull const DIMStation *)server didReceivePackage:(nonnull const NSData *)data {
    DIMTransceiver *trans = [DIMTransceiver sharedInstance];
    
    // decode
    NSString *json = [data UTF8String];
    DIMReliableMessage *rMsg;
    rMsg = [[DKDReliableMessage alloc] initWithJSONString:json];
    
    // check sender
    DIMID *sender = rMsg.envelope.sender;
    DIMMeta *meta = MKMMetaForID(sender);
    if (!meta) {
        meta = rMsg.meta;
        if (!meta) {
            NSLog(@"meta for %@ not found, query from the network...", sender);
            // TODO: insert the message to a temporary queue to waiting meta
            return [self queryMetaForID:sender];
        }
    }
    
    // check receiver
    DIMID *receiver = rMsg.envelope.receiver;
    DIMUser *user = self.currentUser;
    if (MKMNetwork_IsCommunicator(receiver.type)) {
        if ([receiver isEqual:user.ID]) {
            NSLog(@"got message for current user: %@", user);
        } else {
            for (DIMUser *item in self.users) {
                if ([receiver isEqual:item.ID]) {
                    user = item;
                    NSLog(@"got message for user: %@", user);
                }
            }
        }
    } else if (MKMNetwork_IsGroup(receiver.type)) {
        DIMGroup *group = MKMGroupWithID(receiver);
        if ([group existsMember:receiver]) {
            NSLog(@"got group message for current user: %@", user);
        } else {
            for (DIMUser *item in self.users) {
                if ([group existsMember:item.ID]) {
                    user = item;
                    NSLog(@"got group message for user: %@", user);
                }
            }
        }
    } else {
        NSAssert(false, @"receiver type error: %@", receiver);
    }
    
    // trans to instant message
    DKDInstantMessage *iMsg;
    iMsg = [trans verifyAndDecryptMessage:rMsg forUser:user];
    
    // process commands
    DIMMessageContent *content = iMsg.content;
    if (content.type == DIMMessageType_Command) {
        NSString *command = content.command;
        if ([command isEqualToString:@"handshake"]) {
            // handshake
            return [self processHandshakeMessageContent:content];
        } else if ([command isEqualToString:@"meta"]) {
            // query meta response
            return [self processMetaMessageContent:content];
        } else if ([command isEqualToString:@"profile"]) {
            // query profile response
            return [self processProfileMessageContent:content];
        } else if ([command isEqualToString:@"users"]) {
            // query online users response
            return [self processOnlineUsersMessageContent:content];
        } else if ([command isEqualToString:@"search"]) {
            // search users response
            return [self processSearchUsersMessageContent:content];
        } else {
            NSLog(@"!!! unknown command: %@, sender: %@, message content: %@",
                  command, sender, content);
            return ;
        }
    }
    
    if (MKMNetwork_IsStation(sender.type)) {
        NSLog(@"*** message from station: %@", content);
        //return ;
    }
    
    // normal message, let the clerk to deliver it
    DIMAmanuensis *clerk = [DIMAmanuensis sharedInstance];
    [clerk saveMessage:iMsg];
}

@end

@implementation DIMTerminal (Notification)

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject {
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:observer selector:aSelector name:aName object:anObject];
}

- (void)postNotification:(NSNotification *)notification {
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
}

- (void)postNotificationName:(NSNotificationName)aName object:(nullable id)anObject {
    [self postNotificationName:aName object:anObject userInfo:nil];
}

- (void)postNotificationName:(NSNotificationName)aName
                      object:(nullable id)anObject
                    userInfo:(nullable NSDictionary *)aUserInfo {
    NSNotification *noti = [[NSNotification alloc] initWithName:aName
                                                         object:anObject
                                                       userInfo:aUserInfo];
    [self postNotification:noti];
}

- (void)removeObserver:(id)observer {
    [self removeObserver:observer name:nil object:nil];
}

- (void)removeObserver:(id)observer name:(nullable NSNotificationName)aName object:(nullable id)anObject {
    NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
    [dc removeObserver:observer name:aName object:anObject];
}

@end
