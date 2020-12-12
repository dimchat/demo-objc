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

#import "DIMFacebook+Extension.h"
#import "DIMMessenger+Extension.h"
#import "MKMEntity+Extension.h"

#import "DIMAmanuensis.h"

#import "DIMServer.h"

#import "DIMTerminal+Group.h"

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

- (NSArray<MKMUser *> *)users {
    return [_users mutableCopy];
}

- (MKMUser *)currentUser {
    return _currentStation.currentUser;
}

- (void)setCurrentUser:(MKMUser *)user {
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

- (void)addUser:(MKMUser *)user {
    if (user && ![_users containsObject:user]) {
        [_users addObject:user];
    }
    // check current user
    if (!_currentStation.currentUser) {
        _currentStation.currentUser = user;
    }
}

- (void)removeUser:(MKMUser *)user {
    if ([_users containsObject:user]) {
        [_users removeObject:user];
    }
    // check current user
    if ([_currentStation.currentUser isEqual:user]) {
        _currentStation.currentUser = _users.firstObject;
    }
}

- (BOOL)login:(MKMUser *)user {
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

- (void)station:(DIMStation *)server onReceivePackage:(NSData *)data {
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    NSData *response = [messenger processData:data];
    if ([response length] > 0) {
        [_currentStation.star send:response];
    }
}

- (void)station:(DIMStation *)server onHandshakeAccepted:(NSString *)session {
    DIMMessenger *messenger = [DIMMessenger sharedInstance];
    MKMUser *user = self.currentUser;
    // post current profile to station
    id<MKMDocument>profile = [user documentWithType:MKMDocument_Visa];
    if (profile) {
        [messenger postProfile:profile];
    }
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
