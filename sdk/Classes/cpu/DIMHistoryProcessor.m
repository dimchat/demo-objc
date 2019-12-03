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
//  HistoryProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMMessenger.h"

#import "DIMGroupCommandProcessor.h"

#import "DIMHistoryProcessor.h"

@interface DIMHistoryCommandProcessor () {
    
    DIMGroupCommandProcessor *_gpu;
}

@end

@interface DIMCommandProcessor (Hacking)

- (DIMCommandProcessor *)processorForCommand:(NSString *)name;

@end

@implementation DIMHistoryCommandProcessor

- (instancetype)initWithMessenger:(DIMMessenger *)messenger {
    if (self = [super initWithMessenger:messenger]) {
        _gpu = nil;
    }
    return self;
}

- (DIMGroupCommandProcessor *)processor {
    SingletonDispatchOnce(^{
        self->_gpu = [[DIMGroupCommandProcessor alloc] initWithMessenger:self->_messenger];
    });
    return _gpu;
}

//
//  Main
//
- (nullable DIMContent *)processContent:(DIMContent *)content
                                 sender:(DIMID *)sender
                                message:(DIMInstantMessage *)iMsg {
    NSAssert([self isMemberOfClass:[DIMHistoryCommandProcessor class]], @"error!");
    NSAssert([content isKindOfClass:[DIMCommand class]], @"history command error: %@", content);
    // process command content by name
    DIMCommand *cmd = (DIMCommand *)content;
    DIMCommandProcessor *cpu;
    // check group
    if (content.group) {
        // call group command processor
        cpu = [self processor];
        NSAssert(cpu, @"group command processor should not be empty");
    } else {
        // other commands
        cpu = [self processorForCommand:cmd.command];
    }
    if (cpu) {
        NSAssert(cpu != self, @"Dead cycle!");
        return [cpu processContent:content sender:sender message:iMsg];
    }
    NSString *text = [NSString stringWithFormat:@"History command (%@) not support yet!", cmd.command];
    DIMContent *res = [[DIMTextContent alloc] initWithText:text];
    [self.messenger sendContent:res receiver:sender];
    // respond nothing (DON'T respond unknown command directly)
    return nil;
}

@end
