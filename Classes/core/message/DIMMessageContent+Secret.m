//
//  DIMMessageContent+Secret.m
//  DIM
//
//  Created by Albert Moky on 2018/10/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCertifiedMessage.h"

#import "DIMMessageContent+Secret.h"

@interface DIMMessageContent (Hacking)

@property (nonatomic) DIMMessageType type;

@end

@implementation DIMMessageContent (TopSecret)

- (instancetype)initWithSecretMessage:(const DIMCertifiedMessage *)cMsg {
    if (self = [self init]) {
        // type
        self.type = DIMMessageType_Forward;
        
        // top-secret message
        [_storeDictionary setObject:cMsg forKey:@"secret"];
    }
    return self;
}

- (DIMCertifiedMessage *)secretMessage {
    NSDictionary *secret = [_storeDictionary objectForKey:@"secret"];
    if (!secret) {
        secret = [_storeDictionary objectForKey:@"forward"];
        if (!secret) {
            secret = [_storeDictionary objectForKey:@"message"];
        }
    }
    NSAssert(secret, @"data error: %@", _storeDictionary);
    return [DIMCertifiedMessage messageWithMessage:secret];
}

@end
