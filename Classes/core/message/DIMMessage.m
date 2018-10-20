//
//  DIMMessage.m
//  DIM
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMEnvelope.h"

#import "DIMMessage.h"

static NSDate *now() {
    return [[NSDate alloc] init];
}

static NSDate *number_time(const NSNumber *number) {
    NSTimeInterval ti = [number doubleValue];
    if (ti == 0) {
        return now();
    }
    return [[NSDate alloc] initWithTimeIntervalSince1970:ti];
}

@interface DIMMessage ()

@property (strong, nonatomic) DIMEnvelope *envelope;

@end

@implementation DIMMessage

+ (instancetype)messageWithMessage:(id)msg {
    if ([msg isKindOfClass:[DIMMessage class]]) {
        return msg;
    } else if ([msg isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:msg];
    } else {
        NSAssert(!msg, @"unexpected message: %@", msg);
        return nil;
    }
}

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    DIMEnvelope *env = nil;
    self = [self initWithEnvelope:env];
    return self;
}

- (instancetype)initWithSender:(const MKMID *)from
                      receiver:(const MKMID *)to
                          time:(const NSDate *)time {
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
        dict = _storeDictionary;
        
        // envelope
        id from = [dict objectForKey:@"sender"];
        from = [MKMID IDWithID:from];
        id to = [dict objectForKey:@"receiver"];
        to = [MKMID IDWithID:to];
        NSNumber *ti = [dict objectForKey:@"time"];
        NSDate *time = number_time(ti);
        DIMEnvelope *env;
        env = [[DIMEnvelope alloc] initWithSender:from
                                         receiver:to
                                             time:time];
        _envelope = env;
    }
    return self;
}

@end
