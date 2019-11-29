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
//  DIMQuitCommandProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "DIMFacebook.h"

#import "DIMQuitCommandProcessor.h"

@implementation DIMQuitCommandProcessor

- (void)_doQuit:(DIMID *)sender group:(DIMID *)group {
    // existed members
    NSMutableArray<DIMID *> *members = [self convertMembers:[_facebook membersOfGroup:group]];
    if ([members count] == 0) {
        NSAssert(false, @"group members not found: %@", group);
        return;
    }
    if (![members containsObject:sender]) {
        // not a member
        return;
    }
    [members removeObject:sender];
    [_facebook saveMembers:members group:group];
}

//
//  Main
//
- (nullable DIMContent *)processContent:(DIMContent *)content
                                 sender:(DIMID *)sender
                                message:(DIMInstantMessage *)iMsg {
    NSAssert([content isKindOfClass:[DIMQuitCommand class]], @"quit command error: %@", content);
    DIMID *group = [_facebook IDWithString:content.group];
    // 1. check permission
    if ([_facebook group:group isOwner:sender]) {
        NSAssert(false, @"owner cannot quit: %@ -> %@", sender, group);
        return nil;
    }
    if ([_facebook group:group hasAssistant:sender]) {
        NSAssert(false, @"assistant cannot quit now: %@ -> %@", sender, group);
        return nil;
    }
    // 2. remove the sender from group members
    [self _doQuit:sender group:group];
    // 3. response (no need to response this group command)
    return nil;
}

@end
