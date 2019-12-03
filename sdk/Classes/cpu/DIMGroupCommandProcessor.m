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
//  DIMGroupCommandProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMFacebook.h"
#import "DIMMessenger.h"

#import "DIMInviteCommandProcessor.h"
#import "DIMExpelCommandProcessor.h"
#import "DIMQuitCommandProcessor.h"
#import "DIMResetCommandProcessor.h"
#import "DIMQueryCommandProcessor.h"

#import "DIMGroupCommandProcessor.h"

@interface DIMCommandProcessor (Hacking)

- (DIMCommandProcessor *)processorForCommand:(NSString *)name;

@end

static inline void load_cpu_classes(void) {
    [DIMGroupCommandProcessor registerClass:[DIMInviteCommandProcessor class] forCommand:DIMGroupCommand_Invite];
    [DIMGroupCommandProcessor registerClass:[DIMExpelCommandProcessor class] forCommand:DIMGroupCommand_Expel];
    [DIMGroupCommandProcessor registerClass:[DIMQuitCommandProcessor class] forCommand:DIMGroupCommand_Quit];
    [DIMGroupCommandProcessor registerClass:[DIMResetGroupCommandProcessor class] forCommand:DIMGroupCommand_Reset];
    [DIMGroupCommandProcessor registerClass:[DIMQueryGroupCommandProcessor class] forCommand:DIMGroupCommand_Quit];
}

@implementation DIMGroupCommandProcessor

- (instancetype)initWithMessenger:(DIMMessenger *)messenger {
    if (self = [super initWithMessenger:messenger]) {
        
        // register CPU classes
        SingletonDispatchOnce(^{
            load_cpu_classes();
        });
    }
    return self;
}

- (nullable NSArray<DIMID *> *)membersFromCommand:(DIMGroupCommand *)cmd {
    NSArray *members = [cmd members];
    if (!members) {
        NSString *member = [cmd member];
        if (!member) {
            return nil;
        }
        DIMID *ID = [_facebook IDWithString:member];
        NSAssert([ID isValid], @"member ID error: %@", member);
        members = @[ID];
    } else {
        NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:members.count];
        DIMID *member;
        for (NSString *item in members) {
            member = [_facebook IDWithString:item];
            NSAssert([member isValid], @"member ID error: %@", item);
            [mArray addObject:member];
        }
        members = mArray;
    }
    return members;
}

- (nullable NSMutableArray<DIMID *> *)convertMembers:(NSArray *)members {
    if (!members) {
        return [[NSMutableArray alloc] init];
    }
    if ([members count] > 0) {
        NSString *item = [members firstObject];
        if (![item isKindOfClass:[DIMID class]]) {
            // NSString list
            NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:members.count];
            DIMID *ID;
            for (item in members) {
                ID = [_facebook IDWithString:item];
                if (![ID isValid]) {
                    NSAssert(false, @"member ID error: %@", item);
                    continue;
                }
                [mArray addObject:ID];
            }
            return mArray;
        }
    }
    if ([members isKindOfClass:[NSMutableArray class]]) {
        return (NSMutableArray<DIMID *> *)members;
    }
    return [members mutableCopy];
}

- (BOOL)containsOwnerInMembers:(NSArray<DIMID *> *)members group:(DIMID *)group {
    for (DIMID *item in members) {
        if ([_facebook group:group isOwner:item]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isEmpty:(DIMID *)group {
    NSArray *members = [_facebook membersOfGroup:group];
    if ([members count] == 0) {
        return YES;
    }
    DIMID *owner = [_facebook ownerOfGroup:group];
    return !owner;
}

//
//  Main
//
- (nullable DIMContent *)processContent:(DIMContent *)content
                                 sender:(DIMID *)sender
                                message:(DIMInstantMessage *)iMsg {
    NSAssert([self isMemberOfClass:[DIMGroupCommandProcessor class]], @"error!");
    NSAssert([content isKindOfClass:[DIMCommand class]], @"group command error: %@", content);
    // process command content by name
    DIMCommand *cmd = (DIMCommand *)content;
    DIMCommandProcessor *cpu = [self processorForCommand:cmd.command];
    if (cpu) {
        NSAssert(cpu != self, @"Dead cycle!");
        return [cpu processContent:content sender:sender message:iMsg];
    }
    NSString *text = [NSString stringWithFormat:@"Group command (%@) not support yet!", cmd.command];
    DIMContent *res = [[DIMTextContent alloc] initWithText:text];
    [self.messenger sendContent:res receiver:sender];
    // respond nothing (DON'T respond unknown command directly)
    return nil;
}

@end
