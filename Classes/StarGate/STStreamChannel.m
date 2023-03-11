// license: https://mit-license.org
//
//  Star Gate: Network Connection Module
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  STStreamChannel.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/10.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "STStreamChannel.h"

@interface __StreamChannelReader : STChannelReader<NIOSocketChannel *>

@end

@implementation __StreamChannelReader

// Override
- (id<NIOSocketAddress>)receiveWithBuffer:(NIOByteBuffer *)dst {
    if ([self readWithBuffer:dst] > 0) {
        return [self remoteAddress];
    }
    return nil;
}

@end

@interface __StreamChannelWriter : STChannelWriter<NIOSocketChannel *>

@end

@implementation __StreamChannelWriter

// Override
- (NSInteger)sendWithBuffer:(NIOByteBuffer *)src remoteAddress:(id<NIOSocketAddress>)target {
    // TCP channel will be always connected
    // so the target address must be the remote address
    NSAssert(!target || [target isEqual:self.remoteAddress], @"target error: %@, remote: %@", target, self.remoteAddress);
    return [self writeWithBuffer:src];
}

@end

@implementation STStreamChannel

// Override
- (id<STSocketReader>)createReader {
    return [[__StreamChannelReader alloc] initWithChannel:self];
}

// Override
- (id<STSocketWriter>)createWriter {
    return [[__StreamChannelWriter alloc] initWithChannel:self];
}

@end
