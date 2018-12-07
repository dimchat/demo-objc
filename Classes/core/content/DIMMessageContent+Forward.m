//
//  DIMMessageContent+Secret.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMReliableMessage.h"

#import "DIMMessageContent+Forward.h"

@implementation DIMMessageContent (TopSecret)

- (instancetype)initWithForwardMessage:(const DIMReliableMessage *)rMsg {
    if (self = [self initWithType:DIMMessageType_Forward]) {
        // top-secret message
        NSAssert(rMsg, @"forward message cannot be empty");
        [_storeDictionary setObject:rMsg forKey:@"forward"];
    }
    return self;
}

- (DIMReliableMessage *)forwardMessage {
    NSDictionary *msg = [_storeDictionary objectForKey:@"forward"];
    if (!msg) {
        msg = [_storeDictionary objectForKey:@"secret"];
        if (!msg) {
            msg = [_storeDictionary objectForKey:@"message"];
        }
    }
    NSAssert(msg, @"data error: %@", _storeDictionary);
    return [DIMReliableMessage messageWithMessage:msg];
}

@end
