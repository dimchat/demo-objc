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

- (BOOL)isEqual:(id)object {
    DIMConnection *conn = (DIMConnection *)object;
    return [conn.target isEqual:_target];
}

- (BOOL)sendData:(const NSData *)jsonData {
    if (!_connected) {
        NSLog(@"not connected yet");
        return NO;
    }
    NSLog(@"sending data: %@ to station(%@)", [jsonData jsonString], _target.host);
    
    // TODO: send data to target station
    
    return YES;
}

@end
