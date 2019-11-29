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
//  DIMMetaCommandProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "DIMFacebook.h"
#import "DIMReceiptCommand.h"

#import "DIMMetaCommandProcessor.h"

@implementation DIMMetaCommandProcessor

- (nullable DIMContent *)_getMetaForID:(DIMID *)ID {
    // query meta for ID
    DIMMeta *meta = [_facebook metaForID:ID];
    if (meta) {
        return [[DIMMetaCommand alloc] initWithID:ID meta:meta];
    }
    // meta not found
    NSString *text = [NSString stringWithFormat:@"Sorry, meta not found for ID: %@", ID];
    return [[DIMTextContent alloc] initWithText:text];
}

- (nullable DIMContent *)_putMeta:(DIMMeta *)meta
                            forID:(DIMID *)ID {
    NSString *text;
    // received a meta for ID
    if (![_facebook verifyMeta:meta forID:ID]) {
        // meta not match
        text = [NSString stringWithFormat:@"Meta not match ID: %@", ID];
        return [[DIMTextContent alloc] initWithText:text];
    }
    if (![_facebook saveMeta:meta forID:ID]) {
        // save failed
        NSAssert(false, @"failed to save meta for ID: %@, %@", ID, meta);
        return nil;
    }
    text = [NSString stringWithFormat:@"Meta accepted for ID: %@", ID];
    return [[DIMReceiptCommand alloc] initWithMessage:text];
}

//
//  Main
//
- (nullable DIMContent *)processContent:(DIMContent *)content
                                 sender:(DIMID *)sender
                                message:(DIMInstantMessage *)iMsg {
    NSAssert([content isKindOfClass:[DIMMetaCommand class]], @"meta command error: %@", content);
    DIMMetaCommand *cmd = (DIMMetaCommand *)content;
    DIMMeta *meta = cmd.meta;
    DIMID *ID = [_facebook IDWithString:cmd.ID];
    if (meta) {
        return [self _putMeta:meta forID:ID];
    } else {
        return [self _getMetaForID:ID];
    }
}

@end
