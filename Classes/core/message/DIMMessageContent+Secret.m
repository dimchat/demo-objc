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

- (instancetype)initWithForwardMessage:(const DIMCertifiedMessage *)cMsg {
    if (self = [self init]) {
        // type
        self.type = DIMMessageType_Forward;
        
        // top-secret message
        [_storeDictionary setObject:cMsg forKey:@"forward"];
    }
    return self;
}

- (DIMCertifiedMessage *)forwardMessage {
    NSDictionary *message = [_storeDictionary objectForKey:@"forward"];
    if (!message) {
        message = [_storeDictionary objectForKey:@"secret"];
        if (!message) {
            message = [_storeDictionary objectForKey:@"message"];
        }
    }
    NSAssert(message, @"data error: %@", _storeDictionary);
    return [DIMCertifiedMessage messageWithMessage:message];
}

@end
