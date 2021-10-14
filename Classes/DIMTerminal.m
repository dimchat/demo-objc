// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMTerminal.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "NSDate+Timestamp.h"

#import "DIMFacebook+Extension.h"
#import "DIMMessenger+Extension.h"
#import "DIMEntity+Extension.h"

#import "DIMReportCommand.h"

#import "DIMRegister.h"
#import "DIMGroupManager.h"

#import "DIMAmanuensis.h"

#import "DIMServer.h"

#import "DIMTerminal.h"

@interface DIMTerminal ()

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

- (NSString *)language {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    return languages.firstObject;
}

#pragma mark - User(s)

- (NSArray<DIMUser *> *)users {
    return [_users mutableCopy];
}

- (DIMUser *)currentUser {
    return _currentStation.currentUser;
}

- (void)setCurrentUser:(DIMUser *)user {
    _currentStation.currentUser = user;
    if (user && ![_users containsObject:user]) {
        // insert the user to the first
        [_users insertObject:user atIndex:0];
    }
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    facebook.currentUser = user;
    
    //Save current user
    [[NSUserDefaults standardUserDefaults] setObject:user.ID forKey:@"Current_User_ID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

- (BOOL)login:(DIMUser *)user {
    if (!user || [self.currentUser isEqual:user]) {
        NSLog(@"user not change");
        return NO;
    }
    
    // clear session
    _session = nil;
    
    NSLog(@"logout: %@", self.currentUser);
    self.currentUser = user;
    NSLog(@"login: %@", user);
    
    // add to the list of this client
    if (![_users containsObject:user]) {
        [_users addObject:user];
    }
    return YES;
}

#pragma mark DIMStationDelegate

static NSData *sn_start = nil;
static NSData *sn_end = nil;

static inline NSData *fetch_sn(NSData *data) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sn_start = MKMUTF8Encode(@"Mars SN:");
        sn_end = MKMUTF8Encode(@"\n");
    });
    
    NSData *sn = nil;
    NSRange range = NSMakeRange(0, sn_start.length);
    if (data.length > sn_start.length && [[data subdataWithRange:range] isEqualToData:sn_start]) {
        range = NSMakeRange(0, data.length);
        range = [data rangeOfData:sn_end options:0 range:range];
        if (range.location > sn_start.length) {
            range = NSMakeRange(0, range.location + range.length);
            sn = [data subdataWithRange:range];
        }
    }
    return sn;
}

static inline NSData *merge_data(NSData *data1, NSData *data2) {
    NSUInteger len1 = data1.length;
    NSUInteger len2 = data2.length;
    if (len1 == 0) {
        return data2;
    } else if (len2 == 0) {
        return data1;
    }
    NSMutableData *mData = [[NSMutableData alloc] initWithCapacity:(len1 + len2)];
    [mData appendData:data1];
    [mData appendData:data2];
    return mData;
}

static inline bool starts_with(NSData *data, unsigned char b) {
    if ([data length] == 0) {
        return false;
    }
    unsigned char *buffer = (unsigned char *)[data bytes];
    return buffer[0] == b;
}

static inline NSArray<NSData *> *split_lines(NSData *data) {
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *buffer = (unsigned char *)bytes;
        NSUInteger pos1 = byteRange.location, pos2;
        while (pos1 < byteRange.length) {
            pos2 = pos1;
            while (pos2 < byteRange.length) {
                if (buffer[pos2] == '\n') {
                    break;
                } else {
                    ++pos2;
                }
            }
            if (pos2 > pos1) {
                [mArray addObject:[data subdataWithRange:NSMakeRange(pos1, pos2 - pos1)]];
            }
            pos1 = pos2 + 1;  // skip '\n'
        }
    }];
    return mArray;;
}

- (void)station:(DIMStation *)server onReceivePackage:(NSData *)data {
    // 0. fetch SN from data head
    NSData *head = fetch_sn(data);
    if (head.length > 0) {
        NSRange range = NSMakeRange(head.length, data.length - head.length);
        data = [data subdataWithRange:range];
    }
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    NSMutableData *mData = [[NSMutableData alloc] init];
    NSData *SEPARATOR = MKMUTF8Encode(@"\n");
    // 1. split data when multi packages received one time
    NSArray<NSData *> *packages;
    if ([data length] == 0) {
        packages = @[];
    } else if (starts_with(data, '{')) {
        // JSON format
        //     the data buffer may contain multi messages (separated by '\n'),
        //     so we should split them here.
        packages = split_lines(data);
    } else {
        // FIXME: other format?
        packages = @[data];
    }
    NSArray<NSData *> *responses;
    // 2. process package data one by one
    for (NSData *pack in packages) {
        responses = [messenger processData:pack];
        // combine responses
        for (NSData *res in responses) {
            [mData appendData:res];
            [mData appendData:SEPARATOR];
        }
    }
    if ([mData length] > 0) {
        // drop last '\n'
        data = [mData subdataWithRange:NSMakeRange(0, [mData length] - 1)];
    } else {
        data = nil;
    }
    if (head.length > 0 || [data length] > 0) {
        // NOTICE: sending 'SN' back to the server for confirming
        //         that the client have received the pushing message
        [_currentStation.star send:merge_data(head, data)];
    }
}

- (void)station:(DIMStation *)server onHandshakeAccepted:(NSString *)session {
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    DIMUser *user = self.currentUser;
    // post contacts(encrypted) to station
    NSArray<id<MKMID>> *contacts = user.contacts;
    if (contacts) {
        [messenger postContacts:contacts];
    }
    // broadcast login command
    DIMLoginCommand *login = [[DIMLoginCommand alloc] initWithID:user.ID];
    [login setAgent:self.userAgent];
    [login copyStationInfo:server];
    //[login copyProviderInfo:server.SP];
    [messenger broadcastContent:login];
}

@end

@implementation DIMTerminal (GroupManage)

- (nullable DIMGroup *)createGroupWithSeed:(NSString *)seed
                                      name:(NSString *)name
                                   members:(NSArray<id<MKMID>> *)list {
    DIMUser *user = self.currentUser;
    id<MKMID> founder = user.ID;

    // 0. make sure the founder is in the front
    NSUInteger index = [list indexOfObject:founder];
    if (index == NSNotFound) {
        NSAssert(false, @"the founder not found in the member list");
        // add the founder to the front of group members list
        NSMutableArray *mArray = [list mutableCopy];
        [mArray insertObject:founder atIndex:0];
        list = mArray;
    } else if (index != 0) {
        // move the founder to the front
        NSMutableArray *mArray = [list mutableCopy];
        [mArray exchangeObjectAtIndex:index withObjectAtIndex:0];
        list = mArray;
    }
    
    // 1. create profile
    DIMRegister *reg = [[DIMRegister alloc] init];
    DIMGroup *group = [reg createGroupWithSeed:seed name:name founder:founder];
    
    // 2. send out group info
    id<MKMBulletin> profile = [group documentWithType:MKMDocument_Bulletin];
    [self _broadcastGroup:group.ID meta:group.meta profile:profile];
    
    // 4. send out 'invite' command
    DIMGroupManager *gm = [[DIMGroupManager alloc] initWithGroupID:group.ID];
    [gm invite:list];
    
    return group;
}

- (BOOL)_broadcastGroup:(id<MKMID>)ID meta:(nullable id<MKMMeta>)meta profile:(id<MKMDocument>)doc {
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    // create 'profile' command
    DIMCommand *cmd = [[DIMDocumentCommand alloc] initWithID:ID meta:meta document:doc];
    // 1. share to station
    [messenger sendCommand:cmd];
    // 2. send to group assistants
    NSArray<id<MKMID>> *assistants = [facebook assistantsOfGroup:ID];
    for (id<MKMID> ass in assistants) {
        [messenger sendContent:cmd receiver:ass];
    }
    return YES;
}

- (BOOL)updateGroupWithID:(id<MKMID>)group
                  members:(NSArray<id<MKMID>> *)list
                  profile:(nullable id<MKMDocument>)profile {
    DIMGroupManager *gm = [[DIMGroupManager alloc] initWithGroupID:group];
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    id<MKMID> owner = [facebook ownerOfGroup:group];
    NSArray<id<MKMID>> *members = [facebook membersOfGroup:group];
    DIMUser *user = self.currentUser;

    // 1. update profile
    if (profile) {
        [facebook saveDocument:profile];
        [self _broadcastGroup:group meta:nil profile:profile];
    }
    
    // 2. check expel
    NSMutableArray<id<MKMID>> *outMembers = [[NSMutableArray alloc] initWithCapacity:members.count];
    for (id<MKMID> item in members) {
        if ([list containsObject:item]) {
            continue;
        }
        [outMembers addObject:item];
    }
    if ([outMembers count] > 0) {
        // only the owner can expel members
        if (![owner isEqual:user.ID]) {
            NSLog(@"user (%@) not the owner of group: %@", user, group);
            return NO;
        }
        if (![gm expel:outMembers]) {
            NSLog(@"failed to expel members: %@", outMembers);
            return NO;
        }
        NSLog(@"%lu member(s) expeled: %@", outMembers.count, outMembers);
    }
    
    // 3. check invite
    NSMutableArray<id<MKMID>> *newMembers = [[NSMutableArray alloc] initWithCapacity:list.count];
    for (id<MKMID> item in list) {
        if ([members containsObject:item]) {
            continue;
        }
        [newMembers addObject:item];
    }
    if ([newMembers count] > 0) {
        // only the group member can invite new members
        if (![owner isEqual:user.ID] && ![members containsObject:user.ID]) {
            NSLog(@"user (%@) not a member of group: %@", user.ID, group);
            return NO;
        }
        if (![gm invite:newMembers]) {
            NSLog(@"failed to invite members: %@", newMembers);
            return NO;
        }
        NSLog(@"%lu member(s) invited: %@", newMembers.count, newMembers);
    }
    
    return YES;
}

@end

@implementation DIMTerminal (Report)

static NSDate *offlineTime = nil;

- (void)reportOnline {
    DIMUser *user = [self currentUser];
    if (!user) {
        return;
    }
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    DIMStation *server = [messenger currentServer];
    if (!server) {
        return;
    }
    
    DIMCommand *cmd = [[DIMReportCommand alloc] initWithTitle:DIMCommand_Online];
    if (offlineTime) {
        [cmd setObject:NSNumberFromDate(offlineTime) forKey:@"last_time"];
    }
    [messenger sendCommand:cmd];
    
    NSLog(@"[REPORT] user online: %@, %@", user, cmd);
}

- (void)reportOffline {
    DIMUser *user = [self currentUser];
    if (!user) {
        return;
    }
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    DIMStation *server = [messenger currentServer];
    if (!server) {
        return;
    }
    
    DIMCommand *cmd = [[DIMReportCommand alloc] initWithTitle:DIMCommand_Offline];
    offlineTime = [cmd time];
    [messenger sendCommand:cmd];
    
    NSLog(@"[REPORT] user offline: %@, %@", user, cmd);
}

@end
