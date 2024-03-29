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

#import "DIMGroupDelegate.h"

#import "DIMGroupCommandHelper.h"
#import "DIMGroupHistoryBuilder.h"

#import "DIMHistoryProcessor.h"

@interface DIMHistoryCommandProcessor ()

@property (strong, nonatomic) DIMGroupDelegate *delegate;

@property (strong, nonatomic) DIMGroupCommandHelper *helper;
@property (strong, nonatomic) DIMGroupHistoryBuilder *builder;

@end

@implementation DIMHistoryCommandProcessor

- (instancetype)initWithFacebook:(DIMBarrack *)barrack
                       messenger:(DIMTransceiver *)transceiver {
    if (self = [super initWithFacebook:barrack messenger:transceiver]) {
        self.delegate = [self createDelegate];
        self.helper = [self createHelper];
        self.builder = [self createBuilder];
    }
    return self;
}

//
//  Main
//
- (NSArray<id<DKDContent>> *)processContent:(__kindof id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content conformsToProtocol:@protocol(DKDHistoryCommand)],
             @"history error: %@", content);
    id<DKDHistoryCommand> command = content;
    NSDictionary *info = @{
        @"template": @"History command (name: ${command}) not support yet!",
        @"replacements": @{
            @"command": command.cmd,
        },
    };
    return [self respondReceipt:@"Command not support."
                       envelope:rMsg.envelope
                        content:command
                          extra:info];
}

@end

@implementation DIMHistoryCommandProcessor (Delegates)

- (DIMGroupDelegate *)createDelegate {
    return [[DIMGroupDelegate alloc] initWithFacebook:self.facebook
                                            messenger:self.messenger];
}

- (DIMGroupCommandHelper *)createHelper {
    return [[DIMGroupCommandHelper alloc] initWithDelegate:self.delegate];
}

- (DIMGroupHistoryBuilder *)createBuilder {
    return [[DIMGroupHistoryBuilder alloc] initWithDelegate:self.delegate];
}

@end
