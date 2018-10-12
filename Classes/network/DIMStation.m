//
//  DIMStation.m
//  DIM
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMStation.h"

@implementation DIMStation

- (instancetype)initWithHost:(const NSString *)host port:(NSUInteger)port {
    if (self = [self init]) {
        _host = [host copy];
        _port = port;
    }
    return self;
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
