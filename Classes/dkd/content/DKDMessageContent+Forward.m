//
//  DKDMessageContent+Secret.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDReliableMessage.h"

#import "DKDMessageContent+Forward.h"

@implementation DKDMessageContent (TopSecret)

- (instancetype)initWithForwardMessage:(const DKDReliableMessage *)rMsg {
    NSAssert(rMsg, @"forward message cannot be empty");
    if (self = [self initWithType:DKDMessageType_Forward]) {
        // top-secret message
        if (rMsg) {
            [_storeDictionary setObject:rMsg forKey:@"forward"];
        }
    }
    return self;
}

- (DKDReliableMessage *)forwardMessage {
    NSDictionary *msg = [_storeDictionary objectForKey:@"forward"];
    if (!msg) {
        msg = [_storeDictionary objectForKey:@"secret"];
        if (!msg) {
            msg = [_storeDictionary objectForKey:@"message"];
        }
    }
    NSAssert(msg, @"data error: %@", _storeDictionary);
    return [DKDReliableMessage messageWithMessage:msg];
}

@end
