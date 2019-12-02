// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
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
//  DIMConversation.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/9.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMConversation.h"

@interface DIMConversation ()

@property (strong, nonatomic) DIMEntity *entity; // User or Group

@end

@implementation DIMConversation

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    DIMEntity *entity = nil;
    return [self initWithEntity:entity];
}

- (instancetype)initWithEntity:(DIMEntity *)entity {
    if (self = [super init]) {
        _entity = entity;
    }
    return self;
}

- (DIMConversationType)type {
    if (MKMNetwork_IsUser(_entity.type)) {
        return DIMConversationPersonal;
    } else if (MKMNetwork_IsGroup(_entity.type)) {
        return DIMConversationGroup;
    }
    return DIMConversationUnknown;
}

- (DIMID *)ID {
    return _entity.ID;
}

- (NSString *)name {
    return _entity.name;
}

- (NSString *)title {
    DIMConversationType type = self.type;
    if (type == DIMConversationPersonal) {
        DIMUser *user = (DIMUser *)_entity;
        NSString *name = user.name;
        // "xxx"
        return name;
    } else if (type == DIMConversationGroup) {
        DIMGroup *group = (DIMGroup *)_entity;
        NSString *name = group.name;
        unsigned long count = group.members.count;
        // "yyy (123)"
        return [[NSString alloc] initWithFormat:@"%@ (%lu)", name, count];
    }
    NSAssert(false, @"unknown conversation type");
    return @"Conversation";
}

- (nullable DIMProfile *)profile {
    return _entity.profile;
}

#pragma mark - Read from data source

- (NSInteger)numberOfMessage {
    NSAssert(_dataSource, @"set data source handler first");
    return [_dataSource numberOfMessagesInConversation:self];
}

- (DIMInstantMessage *)messageAtIndex:(NSInteger)index {
    NSAssert(_dataSource, @"set data source handler first");
    return [_dataSource conversation:self messageAtIndex:index];
}

- (nullable DIMInstantMessage *)lastMessage {
    NSUInteger count = [_dataSource numberOfMessagesInConversation:self];
    if (count == 0) {
        return nil;
    }
    return [_dataSource conversation:self messageAtIndex:(count - 1)];
}

#pragma mark - Write via delegate

- (BOOL)insertMessage:(DIMInstantMessage *)iMsg {
    NSAssert(_delegate, @"set delegate first");
    BOOL result = [_delegate conversation:self insertMessage:iMsg];
    return result;
}

- (BOOL)removeMessage:(DIMInstantMessage *)iMsg {
    NSAssert(_delegate, @"set delegate first");
    SEL selector = @selector(conversation:removeMessage:);
    if (![_delegate respondsToSelector:selector]) {
        NSAssert(false, @"delegate error");
        return NO;
    }
    
    BOOL result = [_delegate conversation:self removeMessage:iMsg];
    return result;
}

- (BOOL)withdrawMessage:(DIMInstantMessage *)iMsg {
    NSAssert(_delegate, @"set delegate first");
    SEL selector = @selector(conversation:withdrawMessage:);
    if (![_delegate respondsToSelector:selector]) {
        NSAssert(false, @"delegate error");
        return NO;
    }
    BOOL result = [_delegate conversation:self withdrawMessage:iMsg];
    return result;
}

@end
