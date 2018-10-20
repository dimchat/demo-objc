//
//  DIMConnection.m
//  DIM
//
//  Created by Albert Moky on 2018/10/18.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "DIMStation.h"

#import "DIMConnection.h"

@implementation DIMConnection

@synthesize target;
@synthesize connected;

- (instancetype)init {
    DIMStation * station = nil;
    self = [self initWithTargetStation:station];
    return self;
}

/* designated initializer */
- (instancetype)initWithTargetStation:(DIMStation *)station {
    if (self = [super init]) {
        _target = station;
        _connected = NO;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    DIMConnection *conn = (DIMConnection *)object;
    return [conn.target isEqual:_target];
}

#pragma mark Connect / Close

- (BOOL)connectTo:(DIMStation *)station {
    if (_connected) {
        [self close];
    }
    _target = station;
    return [self connect];
}

- (BOOL)connect {
    NSAssert(_target, @"set target station first");
    // let the subclass to do the job
    return YES;
}

- (void)close {
    NSAssert(_target, @"target station cannot be empty");
    // let the subclass to do the job
}

#pragma mark Send / Receive

- (BOOL)sendData:(const NSData *)jsonData {
    if (!_connected) {
        NSLog(@"not connected yet");
        return NO;
    }
    NSLog(@"sending data: %@ to station(%@)", [jsonData jsonString], _target.host);
    
    // let the subclass to the job
    return YES;
}

- (void)receivedData:(NSData *)jsonData {
    NSLog(@"received data: %@", [jsonData UTF8String]);
    NSAssert(_delegate, @"connection delegate cannot be empty");
    [_delegate connection:self didReceiveData:jsonData];
}

@end
