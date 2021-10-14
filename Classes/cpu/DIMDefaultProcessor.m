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
//  DIMDefaultProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 Albert Moky. All rights reserved.
//

#import "DIMFacebook+Extension.h"

#import "DIMDefaultProcessor.h"

@implementation DIMDefaultContentProcessor

//
//  Main
//
- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSString *text = nil;
    
    // File: Image, Audio, Video
    if ([content isKindOfClass:[DIMFileContent class]]) {
        if ([content isKindOfClass:[DIMImageContent class]]) {
            // Image
            text = @"Image received";
        } else if ([content isKindOfClass:[DIMAudioContent class]]) {
            // Audio
            text = @"Voice message received";
        } else if ([content isKindOfClass:[DIMVideoContent class]]) {
            // Video
            text = @"Movie received";
        } else {
            // File
            text = @"File received";
        }
    } else if ([content isKindOfClass:[DIMTextContent class]]) {
        // Text
        NSAssert([content objectForKey:@"text"], @"Text content error: %@", content);
        text = @"Text message received";
    } else if ([content isKindOfClass:[DIMWebpageContent class]]) {
        // Web Page
        NSAssert([content objectForKey:@"URL"], @"Web content error: %@", content);
        text = @"Web page received";
    } else {
        text = [NSString stringWithFormat:@"Content (type: %d) not support yet!", content.type];
        return [self respondText:text withGroup:content.group];
    }
    
    if (content.group) {
        // respond nothing (DON'T respond group message for disturb reason)
        return nil;
    }
    
    // response
    DIMReceiptCommand *res = [[DIMReceiptCommand alloc] initWithMessage:text];
    res.envelope = rMsg.envelope;
    return [self respondContent:res];
}

@end
