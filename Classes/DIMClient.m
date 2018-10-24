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
    }
    return self;
}

- (NSString *)userAgent {
    return @"DIMP/1.0 (iPad; U; iOS 11.4; zh-CN) DIMCoreKit/1.0 (Terminal, like WeChat) DIM-by-GSP/1.0.1";
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

@end
