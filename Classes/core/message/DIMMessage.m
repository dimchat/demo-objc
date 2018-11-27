//
//  DIMMessage.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DIMEnvelope.h"

#import "DIMMessage.h"

@interface DIMMessage ()

@property (strong, nonatomic) DIMEnvelope *envelope;

@end

@implementation DIMMessage

+ (instancetype)messageWithMessage:(id)msg {
    if ([msg isKindOfClass:[DIMMessage class]]) {
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
    DIMEnvelope *env = [[DIMEnvelope alloc] initWithSender:from
                                                  receiver:to
                                                      time:time];
    self = [self initWithEnvelope:env];
    return self;
}

/* designated initializer */
- (instancetype)initWithEnvelope:(const DIMEnvelope *)env {
    NSAssert(env, @"envelope cannot be empty");
    DIMEnvelope *envelope = [DIMEnvelope envelopeWithEnvelope:env];
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
    DIMMessage *msg = [super copyWithZone:zone];
    if (msg) {
        msg.envelope = _envelope;
    }
    return self;
}

- (DIMEnvelope *)envelope {
    if (!_envelope) {
        // sender
        id from = [_storeDictionary objectForKey:@"sender"];
        from = [MKMID IDWithID:from];
        // receiver
        id to = [_storeDictionary objectForKey:@"receiver"];
        to = [MKMID IDWithID:to];
        // time
        NSNumber *timestamp = [_storeDictionary objectForKey:@"time"];
        NSAssert(timestamp, @"error: %@", _storeDictionary);
        NSDate *time = NSDateFromNumber(timestamp);
        
        DIMEnvelope *env;
        env = [[DIMEnvelope alloc] initWithSender:from
                                         receiver:to
                                             time:time];
        _envelope = env;
    }
    return _envelope;
}

@end
