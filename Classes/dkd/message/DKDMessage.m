//
//  DKDMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DKDEnvelope.h"

#import "DKDMessage.h"

@interface DKDMessage ()

@property (strong, nonatomic) DKDEnvelope *envelope;

@end

@implementation DKDMessage

+ (instancetype)messageWithMessage:(id)msg {
    if ([msg isKindOfClass:[DKDMessage class]]) {
        return msg;
    } else if ([msg isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:msg];
    } else if ([msg isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:msg];
    } else {
        NSAssert(!msg, @"unexpected message: %@", msg);
        return nil;
    }
}

- (instancetype)initWithSender:(const MKMID *)from
                      receiver:(const MKMID *)to
                          time:(nullable const NSDate *)time {
    DKDEnvelope *env = [[DKDEnvelope alloc] initWithSender:from
                                                  receiver:to
                                                      time:time];
    self = [self initWithEnvelope:env];
    return self;
}

/* designated initializer */
- (instancetype)initWithEnvelope:(const DKDEnvelope *)env {
    NSAssert(env, @"envelope cannot be empty");
    DKDEnvelope *envelope = [DKDEnvelope envelopeWithEnvelope:env];
    if (self = [super initWithDictionary:envelope]) {
        // envelope
        _envelope = envelope;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // envelope
        _envelope = nil; // lazy
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDMessage *msg = [super copyWithZone:zone];
    if (msg) {
        msg.envelope = _envelope;
    }
    return self;
}

- (DKDEnvelope *)envelope {
    if (!_envelope) {
        // sender
        MKMID *sender = [_storeDictionary objectForKey:@"sender"];
        sender = [MKMID IDWithID:sender];
        NSAssert(sender.isValid, @"sender error");
        
        // receiver
        MKMID *receier = [_storeDictionary objectForKey:@"receiver"];
        receier = [MKMID IDWithID:receier];
        NSAssert(receier.isValid, @"receiver error");
        
        // time
        NSNumber *timestamp = [_storeDictionary objectForKey:@"time"];
        NSAssert(timestamp.doubleValue > 0, @"time error");
        NSDate *time = NSDateFromNumber(timestamp);
        
        _envelope = [[DKDEnvelope alloc] initWithSender:sender
                                               receiver:receier
                                                   time:time];
    }
    return _envelope;
}

@end
