//
//  DIMTerminal+Response.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSNotificationCenter+Extension.h"

#import "DIMServer.h"
#import "DIMTerminal+Request.h"

#import "DIMTerminal+Response.h"

const NSString *kNotificationName_ProfileUpdated = @"ProfileUpdated";
const NSString *kNotificationName_OnlineUsersUpdated = @"OnlineUsersUpdated";
const NSString *kNotificationName_SearchUsersUpdated = @"SearchUsersUpdated";

@implementation DIMTerminal (Response)

- (void)processHandshakeMessageContent:(DIMMessageContent *)content {
    DIMHandshakeCommand *cmd;
    cmd = [[DIMHandshakeCommand alloc] initWithDictionary:content];
    DIMHandshakeState state = cmd.state;
    if (state == DIMHandshake_Success) {
        // handshake OK
        NSLog(@"handshake accepted: %@", self.currentUser);
        NSLog(@"current station: %@", self);
        [_currentStation handshakeAccepted:YES session:_session];
        // post profile
        DIMProfile *profile = DIMProfileForID(self.currentUser.ID);
        [self postProfile:profile meta:nil];
    } else if (state == DIMHandshake_Again) {
        // update session and handshake again
        NSString *session = cmd.sessionKey;
        NSLog(@"session %@ -> %@", _session, session);
        _session = session;
        [_currentStation handshakeWithSession:session];
    } else {
        NSLog(@"handshake rejected: %@", content);
        [_currentStation handshakeAccepted:NO session:nil];
    }
}

- (void)processMetaMessageContent:(DIMMessageContent *)content {
    DIMMetaCommand *cmd;
    cmd = [[DIMMetaCommand alloc] initWithDictionary:content];
    // check meta
    const DIMMeta *meta = cmd.meta;
    if ([meta matchID:cmd.ID]) {
        NSLog(@"got new meta for %@", cmd.ID);
        DIMBarrack *barrack = [DIMBarrack sharedInstance];
        [barrack saveMeta:cmd.meta forEntityID:cmd.ID];
    }
}

- (void)processProfileMessageContent:(DIMMessageContent *)content {
    DIMProfileCommand *cmd;
    cmd = [[DIMProfileCommand alloc] initWithDictionary:content];
    // check meta
    const DIMMeta *meta = cmd.meta;
    if (meta) {
        NSAssert([meta matchID:cmd.ID], @"meta not match ID: %@", cmd);
        NSLog(@"got new meta for %@", cmd.ID);
        DIMBarrack *barrack = [DIMBarrack sharedInstance];
        [barrack saveMeta:cmd.meta forEntityID:cmd.ID];
    }
    // check profile
    DIMProfile *profile = cmd.profile;
    if (profile) {
        NSAssert([profile.ID isEqual:cmd.ID], @"profile not match ID: %@", cmd);
        NSLog(@"got new profile for %@", cmd.ID);
        [NSNotificationCenter postNotificationName:kNotificationName_ProfileUpdated object:self userInfo:cmd];
    }
}

- (void)processOnlineUsersMessageContent:(DIMMessageContent *)content {
    NSArray *users = [content objectForKey:@"users"];
    NSDictionary *info = @{@"users": users};
    [NSNotificationCenter postNotificationName:kNotificationName_OnlineUsersUpdated object:self userInfo:info];
}

- (void)processSearchUsersMessageContent:(DIMMessageContent *)content {
    NSArray *users = [content objectForKey:@"users"];
    NSDictionary *results = [content objectForKey:@"results"];
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (users) {
        [mDict setObject:users forKey:@"users"];
    }
    if (results) {
        [mDict setObject:results forKey:@"results"];
    }
    [NSNotificationCenter postNotificationName:kNotificationName_SearchUsersUpdated object:self userInfo:mDict];
}

@end
