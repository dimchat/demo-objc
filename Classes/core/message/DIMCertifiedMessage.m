//
//  DIMCertifiedMessage.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMCertifiedMessage.h"

@interface DIMCertifiedMessage ()

@property (strong, nonatomic) NSData *signature;

@end

@implementation DIMCertifiedMessage

- (instancetype)initWithData:(const NSData *)content
                encryptedKey:(const NSData *)key
                    envelope:(const DIMEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    NSData *CT = nil;
    self = [self initWithData:content
                    signature:CT
                 encryptedKey:key
                     envelope:env];
    return self;
}

- (instancetype)initWithData:(const NSData *)content
               encryptedKeys:(const DIMEncryptedKeyMap *)keys
                    envelope:(const DIMEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    NSData *CT = nil;
    self = [self initWithData:content
                    signature:CT
                encryptedKeys:keys
                     envelope:env];
    return self;
}

/* designated initializer */
- (instancetype)initWithData:(const NSData *)content
                   signature:(const NSData *)CT
                encryptedKey:(const NSData *)key
                    envelope:(const DIMEnvelope *)env {
    NSAssert(CT, @"signature cannot be empty");
    if (self = [super initWithData:content
                      encryptedKey:key
                          envelope:env]) {
        // signature
        if (CT) {
            [_storeDictionary setObject:[CT base64Encode] forKey:@"signature"];
            _signature = [CT copy];
        }
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithData:(const NSData *)content
                   signature:(const NSData *)CT
               encryptedKeys:(const DIMEncryptedKeyMap *)keys
                    envelope:(const DIMEnvelope *)env {
    NSAssert(CT, @"signature cannot be empty");
    if (self = [super initWithData:content
                     encryptedKeys:keys
                          envelope:env]) {
        // signature
        if (CT) {
            [_storeDictionary setObject:[CT base64Encode] forKey:@"signature"];
            _signature = [CT copy];
        }
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _signature = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMCertifiedMessage *cMsg = [super copyWithZone:zone];
    if (cMsg) {
        cMsg.signature = _signature;
    }
    return cMsg;
}

- (NSData *)signature {
    if (!_signature) {
        NSString *CT = [_storeDictionary objectForKey:@"signature"];
        NSAssert(CT, @"signature cannot be empty");
        _signature = [CT base64Decode];
    }
    return _signature;
}

@end
