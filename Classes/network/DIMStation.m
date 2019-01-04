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

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                 publicKey:(const MKMPublicKey *)PK {
    if (self = [super initWithID:ID publicKey:PK]) {
        _host = nil;
        _port = 9394;
        _SP = nil;
        _CA = nil;
        _delegate = nil;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    // ID
    DIMID *ID = [dict objectForKey:@"ID"];
    ID = [DIMID IDWithID:ID];
    // public key
    DIMPublicKey *PK = [dict objectForKey:@"PK"];
    PK = [DIMPublicKey keyWithKey:PK];
    
    // host
    NSString *host = [dict objectForKey:@"host"];
    // port
    NSNumber *port = [dict objectForKey:@"port"];
    if (!port) {
        port = @(9394);
    }
    // SP
    id SP = [dict objectForKey:@"SP"];
    if ([SP isKindOfClass:[NSDictionary class]]) {
        SP = [[DIMServiceProvider alloc] initWithDictionary:SP];
    }
    // CA
    DIMCertificateAuthority *CA = [dict objectForKey:@"CA"];
    CA = [DIMCertificateAuthority caWithCA:CA];
    
    if (!PK) {
        PK = CA.info.publicKey;
    }
    
    if (self = [self initWithID:ID publicKey:PK]) {
        _host = host;
        _port = [port unsignedIntegerValue];
        
        _SP = SP;
        _CA = CA;
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
    if ([station.ID isEqual:_ID]) {
        return YES;
    }
    if ([station.host isEqualToString:_host] && station.port == _port) {
        return YES;
    }
    return NO;
}

- (NSString *)name {
    DIMCASubject *subject = self.CA.info.subject;
    if (subject.commonName) {
        return subject.commonName;
    } else if (subject.organization) {
        return subject.organization;
    } else {
        return [super name];
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
