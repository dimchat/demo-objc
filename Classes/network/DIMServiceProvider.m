//
//  DIMServiceProvider.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMStation.h"

#import "DIMServiceProvider.h"

@implementation DIMServiceProvider

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                 founderID:(const MKMID *)founderID {
    if (self = [super initWithID:ID founderID:founderID]) {
        _CA = nil;
        _home = nil;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    // ID
    DIMID *ID = [dict objectForKey:@"ID"];
    ID = [DIMID IDWithID:ID];
    // founder
    DIMID *founder = [dict objectForKey:@"founder"];
    founder = [DIMID IDWithID:founder];
    // owner
    DIMID *owner = [dict objectForKey:@"owner"];
    owner = [DIMID IDWithID:owner];
    
    // CA
    DIMCertificateAuthority *CA = [dict objectForKey:@"CA"];
    CA = [DIMCertificateAuthority caWithCA:CA];
    // home
    id home = [dict objectForKey:@"home"];
    if ([home isKindOfClass:[NSString class]]) {
        home = [NSURL URLWithString:home];
    }
    
    if (self = [self initWithID:ID founderID:founder]) {
        _owner = owner;
        
        _CA = CA;
        _home = home;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMServiceProvider *SP = [super copyWithZone:zone];
    if (SP) {
        SP.CA = _CA;
        SP.home = _home;
    }
    return SP;
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

#pragma mark Station

- (BOOL)verifyStation:(const DIMStation *)station {
    DIMCertificateAuthority *CA = station.CA;
    return [CA verifyWithPublicKey:self.publicKey];
}

@end
