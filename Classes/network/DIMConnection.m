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

@interface DIMConnection ()

@property (strong, nonatomic) DIMStation *target;
@property (nonatomic, getter=isConnected) BOOL connected;

@end

@implementation DIMConnection

- (instancetype)init {
    DIMStation * station = nil;
    self = [self initWithTargetStation:station];
    return self;
}

/* designated initializer */
- (instancetype)initWithTargetStation:(const DIMStation *)station {
    if (self = [super init]) {
        _target = [station copy];
        _connected = NO;
    }
    return self;
}

- (BOOL)connect {
    NSString *IP = _target.host;
    NSUInteger port = _target.port;
    NSLog(@"connecting to %@:%lu ...", IP, port);
    
    // TODO: connect to target station
    _connected = YES;
    
    return YES;
}

- (void)disconnect {
    // TODO: disconnect the current connection
    _connected = NO;
    
    NSLog(@"disconnected");
}

- (BOOL)sendData:(const NSData *)jsonData {
    if (!_connected) {
        NSLog(@"not connected yet");
        return NO;
    }
    NSLog(@"sending data: %@", [jsonData jsonString]);
    
    // TODO: send data to target station
    
    return YES;
}

@end
