//
//  DIMCertifiedMessage.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMCertifiedMessage.h"

@interface DIMCertifiedMessage ()

@property (strong, nonatomic) const NSData *signature;

@end

@implementation DIMCertifiedMessage

- (instancetype)initWithContent:(const NSData *)content
                       envelope:(const DIMEnvelope *)env
                      secretKey:(const NSData *)key {
    NSAssert(false, @"DON'T call me");
    NSData *CT = nil;
    self = [self initWithContent:content
                        envelope:env
                       secretKey:key
                       signature:CT];
    return self;
}

- (instancetype)initWithContent:(const NSData *)content
                       envelope:(const DIMEnvelope *)env
                      secretKey:(const NSData *)key
                      signature:(const NSData *)CT {
    NSAssert(CT, @"signature cannot be empty");
    self = [super initWithContent:content
                        envelope:env
                       secretKey:key];
    if (self) {
        // signature
        if (CT) {
            [_storeDictionary setObject:[CT base64Encode]
                                 forKey:@"signature"];
            self.signature = CT;
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
