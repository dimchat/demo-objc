//
//  DKDEnvelope.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

#import "DKDEnvelope.h"

@interface DKDEnvelope ()

@property (strong, nonatomic) MKMID *sender;
@property (strong, nonatomic) MKMID *receiver;

@property (strong, nonatomic) NSDate *time;

@end

@implementation DKDEnvelope

+ (instancetype)envelopeWithEnvelope:(id)env {
    if ([env isKindOfClass:[DKDEnvelope class]]) {
        return env;
    } else if ([env isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:env];
    } else if ([env isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:env];
    } else {
        NSAssert(!env, @"unexpected envelope: %@", env);
        return nil;
    }
}

/* designated initializer */
- (instancetype)initWithSender:(const MKMID *)from
                      receiver:(const MKMID *)to
                          time:(nullable const NSDate *)time {
    if (!time) {
        // now()
        time = [[NSDate alloc] init];
    }
    NSDictionary *dict = @{@"sender"  :from,
                           @"receiver":to,
                           @"time"    :NSNumberFromDate(time),
                           };
    if (self = [super initWithDictionary:dict]) {
        _sender = [from copy];
        _receiver = [to copy];
        _time = [time copy];
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _sender = nil;
        _receiver = nil;
        _time = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DKDEnvelope *env = [super copyWithZone:zone];
    if (env) {
        env.sender = _sender;
        env.receiver = _receiver;
        env.time = _time;
    }
    return env;
}

- (MKMID *)sender {
    if (!_sender) {
        id from = [_storeDictionary objectForKey:@"sender"];
        _sender = [MKMID IDWithID:from];
    }
    return _sender;
}

- (MKMID *)receiver {
    if (!_receiver) {
        id to = [_storeDictionary objectForKey:@"receiver"];
        _receiver = [MKMID IDWithID:to];
    }
    return _receiver;
}

- (NSDate *)time {
    if (!_time) {
        NSNumber *timestamp = [_storeDictionary objectForKey:@"time"];
        NSAssert(timestamp, @"error: %@", _storeDictionary);
        _time = NSDateFromNumber(timestamp);
    }
    return _time;
}

@end
