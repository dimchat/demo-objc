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

#import "MKMEntity+Extension.h"

#import "DIMConversation.h"

@interface DIMConversation ()

@property (strong, nonatomic) MKMEntity *entity; // User or Group

@end

@implementation DIMConversation

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    MKMEntity *entity = nil;
    return [self initWithEntity:entity];
}

- (instancetype)initWithEntity:(MKMEntity *)entity {
    if (self = [super init]) {
        _entity = entity;
    }
    return self;
}

- (DIMConversationType)type {
    if (MKMIDIsUser(_entity.ID)) {
        return DIMConversationPersonal;
    } else if (MKMIDIsGroup(_entity.ID)) {
        return DIMConversationGroup;
    }
    return DIMConversationUnknown;
}

- (id<MKMID>)ID {
    return _entity.ID;
}

- (NSString *)name {
    return _entity.name;
}

- (NSString *)title {
    DIMConversationType type = self.type;
    if (type == DIMConversationPersonal) {
        MKMUser *user = (MKMUser *)_entity;
        NSString *name = user.name;
        // "xxx"
        return name;
    } else if (type == DIMConversationGroup) {
        MKMGroup *group = (MKMGroup *)_entity;
        NSString *name = group.name;
        unsigned long count = group.members.count;
        // "yyy (123)"
        return [[NSString alloc] initWithFormat:@"%@ (%lu)", name, count];
    }
    NSAssert(false, @"unknown conversation type");
    return @"Conversation";
}

- (nullable __kindof id<MKMDocument>)profile {
    return [_entity documentWithType:@"*"];
}

#pragma mark - Read from data source

- (NSInteger)numberOfMessage {
    NSAssert(_dataSource, @"set data source handler first");
    return [_dataSource numberOfMessagesInConversation:self.ID];
}

- (id<DKDInstantMessage>)messageAtIndex:(NSInteger)index {
    NSAssert(_dataSource, @"set data source handler first");
    return [_dataSource conversation:self.ID messageAtIndex:index];
}

#pragma mark - Write via delegate

- (BOOL)insertMessage:(id<DKDInstantMessage>)iMsg {
    NSAssert(_delegate, @"set delegate first");
    BOOL result = [_delegate conversation:self.ID insertMessage:iMsg];
    return result;
}

- (BOOL)removeMessage:(id<DKDInstantMessage>)iMsg {
    NSAssert(_delegate, @"set delegate first");
    SEL selector = @selector(conversation:removeMessage:);
    if (![_delegate respondsToSelector:selector]) {
        NSAssert(false, @"delegate error");
        return NO;
    }
    
    BOOL result = [_delegate conversation:self.ID removeMessage:iMsg];
    return result;
}

- (BOOL)withdrawMessage:(id<DKDInstantMessage>)iMsg {
    NSAssert(_delegate, @"set delegate first");
    SEL selector = @selector(conversation:withdrawMessage:);
    if (![_delegate respondsToSelector:selector]) {
        NSAssert(false, @"delegate error");
        return NO;
    }
    BOOL result = [_delegate conversation:self.ID withdrawMessage:iMsg];
    return result;
}

@end
