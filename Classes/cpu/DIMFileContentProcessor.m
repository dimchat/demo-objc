// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2020 Albert Moky
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
//  DIMFileContentProcessor.m
//  DIMSDK
//
//  Created by Albert Moky on 2020/12/11.
//  Copyright © 2020 Albert Moky. All rights reserved.
//

#import "DIMFileContentProcessor.h"

@implementation DIMFileContentProcessor

- (id<DIMMessengerDelegate>)delegate {
    return [self.messenger delegate];
}

- (BOOL)uploadFileContent:(id<DIMFileContent>)content
                      key:(id<MKMSymmetricKey>)pwd
                  message:(id<DKDInstantMessage>)iMsg {
    NSData *data = content.fileData;
    if (data.length == 0) {
        NSAssert(false, @"failed to get file data: %@", content);
        return NO;
    }
    // encrypt and upload file data onto CDN and save the URL in message content
    NSData *CT = [pwd encrypt:data];
    if (CT.length == 0) {
        NSAssert(false, @"failed to encrypt file data with key: %@", pwd);
        return NO;
    }
    NSURL *url = [self.messenger uploadData:CT forMessage:iMsg];
    if (url) {
        content.URL = url;
        content.fileData = nil;
        return YES;
    }
    return NO;
}

- (BOOL)downloadFileContent:(id<DIMFileContent>)content
                        key:(id<MKMSymmetricKey>)pwd
                    message:(id<DKDSecureMessage>)sMsg {
    NSURL *url = content.URL;
    if (!url) {
        // download URL not found
        return NO;
    }
    id<DKDInstantMessage> iMsg = DKDInstantMessageCreate(sMsg.envelope, content);
    NSData *CT = [self.messenger downloadData:url forMessage:iMsg];
    if (CT.length == 0) {
        // save symmetric key for decrypting file data after download from CDN
        content.password = pwd;
        return NO;
    } else {
        // decrypt file data
        NSData *data = [pwd decrypt:CT];
        if (data.length == 0) {
            NSAssert(false, @"failed to decrypt file data with key: %@", pwd);
            return NO;
        }
        content.fileData = data;
        content.URL = nil;
        return YES;
    }
}

//
//  Main
//
- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content
                                withMessage:(id<DKDReliableMessage>)rMsg {
    NSAssert([content isKindOfClass:[DIMFileContent class]], @"file content error: %@", content);
    // TODO: process file content
    
    return nil;
}

@end
