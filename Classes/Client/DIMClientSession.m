// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
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
//  DIMClientSession.m
//  DIMClient
//
//  Created by Albert Moky on 2023/3/10.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "STStreamArrival.h"
#import "DIMClientSession+State.h"

#import "DIMClientSession.h"

static NSData *sn_start = nil;
static NSData *sn_end = nil;

static inline NSData *fetch_sn(NSData *data) {
    OKSingletonDispatchOnce(^{
        sn_start = MKMUTF8Encode(@"Mars SN:");
        sn_end = MKMUTF8Encode(@"\n");
    });

    NSData *sn = nil;
    NSRange range = NSMakeRange(0, sn_start.length);
    if (data.length > sn_start.length && [[data subdataWithRange:range] isEqualToData:sn_start]) {
        range = NSMakeRange(0, data.length);
        range = [data rangeOfData:sn_end options:0 range:range];
        if (range.location > sn_start.length) {
            range = NSMakeRange(0, range.location + range.length);
            sn = [data subdataWithRange:range];
        }
    }
    return sn;
}

static inline NSData *merge_data(NSData *data1, NSData *data2) {
    NSUInteger len1 = data1.length;
    NSUInteger len2 = data2.length;
    if (len1 == 0) {
        return data2;
    } else if (len2 == 0) {
        return data1;
    }
    NSMutableData *mData = [[NSMutableData alloc] initWithCapacity:(len1 + len2)];
    [mData appendData:data1];
    [mData appendData:data2];
    return mData;
}

static inline bool starts_with(NSData *data, unsigned char b) {
    if ([data length] == 0) {
        return false;
    }
    unsigned char *buffer = (unsigned char *)[data bytes];
    return buffer[0] == b;
}

static inline NSArray<NSData *> *split_lines(NSData *data) {
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *buffer = (unsigned char *)bytes;
        NSUInteger pos1 = byteRange.location, pos2;
        while (pos1 < byteRange.length) {
            pos2 = pos1;
            while (pos2 < byteRange.length) {
                if (buffer[pos2] == '\n') {
                    break;
                } else {
                    ++pos2;
                }
            }
            if (pos2 > pos1) {
                [mArray addObject:[data subdataWithRange:NSMakeRange(pos1, pos2 - pos1)]];
            }
            pos1 = pos2 + 1;  // skip '\n'
        }
    }];
    return mArray;
}

@interface DIMClientSession () {
    
    NSString *_key;
}

@property(nonatomic, strong) __kindof id<MKMStation> station;

@property(nonatomic, strong) DIMSessionStateMachine *fsm;

@property(nonatomic, strong) NSString *key;

@property(nonatomic, strong) SMThread *thread;

@end

@implementation DIMClientSession

- (instancetype)initWithDatabase:(id<DIMSessionDBI>)db
                         station:(id<MKMStation>)server {
    id<NIOSocketAddress> remote;
    remote = [[NIOInetSocketAddress alloc] initWithHost:server.host
                                                   port:server.port];
    if (self = [super initWithDatabase:db
                         remoteAddress:remote
                         socketChannel:nil]) {
        _station = server;
        _fsm = [[DIMSessionStateMachine alloc] initWithSession:self];
        _thread = nil;
        _key = nil;
        _thread = nil;
    }
    return self;
}

- (id<MKMStation>)station {
    return _station;
}

- (DIMSessionState *)state {
    return [_fsm currentState];
}

- (NSString *)key {
    return _key;
}

- (void)setKey:(nullable NSString *)key {
    _key = key;
}

- (void)startWithStateDelegate:(id<DIMSessionStateDelegate>) delegate {
//    [self stop];
    
    NSAssert(!_thread, @"already started");
    SMThread *thr = [[SMThread alloc] initWithTarget:self];
    [thr start];
    _thread = thr;
    
    // start state machine
    _fsm.delegate = delegate;
    [_fsm start];
}

- (void)pause {
    [_fsm pause];
}

- (void)resume {
    [_fsm resume];
}

// Override
- (void)stop {
    [super stop];
    
    // stop state machine
    [_fsm stop];
    
    NSAssert(_thread, @"not start yet");
    SMThread *thr = _thread;
    [thr cancel];
    _thread = nil;
}

// Override
- (void)setup {
    [self setActive:YES time:0];
    [super setup];
}

// Override
- (void)finish {
    [super finish];
    [self setActive:NO time:0];
}

//
//  Docker Delegate
//

// Override
- (void)docker:(id<STDocker>)worker changedStatus:(STDockerStatus)previous
      toStatus:(STDockerStatus)current {
    //[super docker:worker changedStatus:previous toStatus:current];
    if (current == STDockerStatusError) {
        // connection error or session finished
        // TODO: reconnect?
        [self setActive:NO time:0];
        // TODO: clear session ID and handshake again
    } else if (current == STDockerStatusReady) {
        // connected/ reconnected
        [self setActive:YES time:0];
    }
}

// Override
- (void)docker:(id<STDocker>)worker receivedShip:(id<STArrival>)arrival {
    //[super docker:worker receivedShip:arrival];
    STStreamArrival *ship = (STStreamArrival *)arrival;
    NSData *data = [ship payload];
    
    // 0. fetch SN from data head
    NSData *head = fetch_sn(data);
    if (head.length > 0) {
        NSRange range = NSMakeRange(head.length, data.length - head.length);
        data = [data subdataWithRange:range];
        NSLog(@"got data with head [%@] body: %lu byte(s)", MKMUTF8Decode(head), [data length]);
    }
    
    // 1. split data when multi packages received one time
    NSArray<NSData *> *packages;
    if ([data length] == 0) {
        packages = @[];
    } else if (starts_with(data, '{')) {
        // JSON format
        //     the data buffer may contain multi messages (separated by '\n'),
        //     so we should split them here.
        packages = split_lines(data);
    } else {
        // FIXME: other format?
        packages = @[data];
    }
    id<NIOSocketAddress> source = [worker remoteAddress];

    // 2. process package data one by one
    NSData *SEPARATOR = MKMUTF8Encode(@"\n");
    NSMutableData *mData = [[NSMutableData alloc] init];
    NSArray<NSData *> *responses;
    for (NSData *pack in packages) {
        responses = [self processData:pack fromRemote:source];
        // combine responses
        for (NSData *res in responses) {
            [mData appendData:res];
            [mData appendData:SEPARATOR];
        }
    }
    if ([mData length] > 0) {
        // drop last '\n'
        data = [mData subdataWithRange:NSMakeRange(0, [mData length] - 1)];
    } else {
        data = nil;
    }
    if (head.length > 0 || [data length] > 0) {
        // NOTICE: sending 'SN' back to the server for confirming
        //         that the client have received the pushing message
        STCommonGate *gate = [self gate];
        id<NIOSocketAddress> destination = [worker localAddress];
        [gate sendResponse:merge_data(head, data)
            forArrivalShip:arrival
             remoteAddress:source
              localAddress:destination];
    }
}

@end

@implementation DIMClientSession (Pack)

+ (NSArray<NSData *> *)fetchDataPackages:(id<STArrival>)arrival {
    STStreamArrival *ship = (STStreamArrival *)arrival;
    NSData *payload = [ship payload];
    // check payload
    if (payload.length == 0) {
        return @[];
    } else {
        // TODO: split JsON in lines
        return @[payload];
    }
}

@end

@implementation DIMClientSession (Process)

- (NSArray<NSData *> *)processData:(NSData *)pack
                        fromRemote:(id<NIOSocketAddress>)source {
    DIMMessenger *messenger = [self messenger];
    return [messenger processPackage:pack];
}

@end
