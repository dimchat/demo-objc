//
//  DIMClient.m
//  DIM
//
//  Created by Albert Moky on 2018/10/16.
//  Copyright © 2018 DIM Group. All rights reserved.
//

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

@end
