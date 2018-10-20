//
//  DIMCertifiedMessage.m
//  DIM
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
                    envelope:(const DIMEnvelope *)env
                encryptedKey:(const NSData *)key {
    NSAssert(false, @"DON'T call me");
    NSData *CT = nil;
    self = [self initWithData:content
                     envelope:env
                 encryptedKey:key
                    signature:CT];
    return self;
}

- (instancetype)initWithData:(const NSData *)content
                    envelope:(const DIMEnvelope *)env
               encryptedKeys:(const DIMEncryptedKeyMap *)keys {
    NSAssert(false, @"DON'T call me");
    NSData *CT = nil;
    self = [self initWithData:content
                     envelope:env
                encryptedKeys:keys
                    signature:CT];
    return self;
}

- (instancetype)initWithData:(const NSData *)content
                    envelope:(const DIMEnvelope *)env
                encryptedKey:(const NSData *)key
                   signature:(const NSData *)CT {
    NSAssert(CT, @"signature cannot be empty");
    if (self = [super initWithData:content
                          envelope:env
                      encryptedKey:key]) {
        // signature
        if (CT) {
            [_storeDictionary setObject:[CT base64Encode] forKey:@"signature"];
            _signature = [CT copy];
        }
    }
    return self;
}

- (instancetype)initWithData:(const NSData *)content
                    envelope:(const DIMEnvelope *)env
               encryptedKeys:(const DIMEncryptedKeyMap *)keys
                   signature:(const NSData *)CT {
    NSAssert(CT, @"signature cannot be empty");
    if (self = [super initWithData:content
                          envelope:env
                     encryptedKeys:keys]) {
        // signature
        if (CT) {
            [_storeDictionary setObject:[CT base64Encode] forKey:@"signature"];
            _signature = [CT copy];
        }
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        NSString *CT = [dict objectForKey:@"signature"];
        self.signature = [CT base64Decode];
    }
    return self;
}

@end
