//
//  DIMStation.m
//  DIM
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMStation.h"

@implementation DIMStation

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    NSString *host = @"s0.gsp.dim.net";
    self = [self initWithHost:host port:9527];
    return self;
}

- (instancetype)initWithHost:(const NSString *)host {
    self = [self initWithHost:host port:9527];
    return self;
}

/* designated initializer */
- (instancetype)initWithHost:(const NSString *)host port:(NSUInteger)port {
    if (self = [super init]) {
        _host = [host copy];
        _port = port;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    DIMStation *station = (DIMStation *)object;
    return [station.host isEqualToString:_host] && station.port == _port;
}

- (NSString *)name {
    NSString *str = _CA.info.subject.commonName;
    if (!str) {
        str = _CA.info.subject.organization;
    }
    return str;
}

- (MKMPublicKey *)publicKey {
    return _CA.info.publicKey;
}

@end
