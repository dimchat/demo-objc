//
//  DIMStation.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMServiceProvider.h"

#import "DIMStation.h"

@interface DIMStation ()

@property (strong, nonatomic) NSString *host;
@property (nonatomic) NSUInteger port;

@end

@implementation DIMStation

+ (instancetype)stationWithStation:(id)station {
    if ([station isKindOfClass:[DIMStation class]]) {
        return station;
    } else if ([station isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:station];
    } else if ([station isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:station];
    } else {
        NSAssert(!station, @"unexpected station: %@", station);
        return nil;
    }
}

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    if (self = [super init]) {
        _host = nil;
        _port = 0;
        _SP = nil;
        _CA = nil;
        _delegate = nil;
    }
    return self;
}

- (instancetype)initWithHost:(const NSString *)host {
    self = [self initWithHost:host port:9394];
    return self;
}

- (instancetype)initWithHost:(const NSString *)host port:(NSUInteger)port {
    NSDictionary *dict = @{@"host":host, @"port":@(port)};
    if (self = [self initWithDictionary:dict]) {
        _host = [host copy];
        _port = port;
        _SP = nil;
        _CA = nil;
        _delegate = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMStation *station = [super copyWithZone:zone];
    if (station) {
        station.host = _host;
        station.port = _port;
        //station.SP = _SP;
        //station.CA = _CA;
        station.delegate = _delegate;
    }
    return station;
}

- (BOOL)isEqual:(id)object {
    DIMStation *station = (DIMStation *)object;
    return [station.host isEqualToString:_host] && station.port == _port;
}

- (NSString *)host {
    if (!_host) {
        _host = [_storeDictionary objectForKey:@"host"];
    }
    return _host;
}

- (NSUInteger)port {
    if (_port == 0) {
        NSNumber *num = [_storeDictionary objectForKey:@"port"];
        _port = [num unsignedIntegerValue];
    }
    return _port;
}

#pragma mark Service Provider

- (DIMServiceProvider *)SP {
    if (!_SP) {
        DIMServiceProvider *p = [_storeDictionary objectForKey:@"SP"];
        _SP = [DIMServiceProvider providerWithProvider:p];
    }
    return _SP;
}

- (void)setSP:(DIMServiceProvider *)SP {
    if (SP) {
        [_storeDictionary setObject:SP forKey:@"SP"];
    } else {
        [_storeDictionary removeObjectForKey:@"SP"];
    }
    _SP = SP;
}

#pragma mark Certificate Authority

- (DIMCertificateAuthority *)CA {
    if (!_CA) {
        DIMCertificateAuthority *a = [_storeDictionary objectForKey:@"CA"];
        _CA = [DIMCertificateAuthority caWithCA:a];
    }
    return _CA;
}

- (void)setCA:(DIMCertificateAuthority *)CA {
    if (CA) {
        [_storeDictionary setObject:CA forKey:@"CA"];
    } else {
        [_storeDictionary removeObjectForKey:@"CA"];
    }
    _CA = CA;
}

- (NSString *)name {
    DIMCASubject *subject = self.CA.info.subject;
    if (subject.commonName) {
        return subject.commonName;
    } else {
        return subject.organization;
    }
}

- (DIMPublicKey *)publicKey {
    return self.CA.info.publicKey;
}

- (NSURL *)home {
    return self.SP.home;
}

#pragma mark - DIMTransceiverDelegate

- (BOOL)sendPackage:(const NSData *)data
  completionHandler:(nullable DIMTransceiverCompletionHandler)handler {
    // TODO: override me
    
    return NO;
}

@end
