//
//  DIMEnvelope.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMEnvelope.h"

static NSDate *now() {
    return [[NSDate alloc] init];
}

static NSNumber *time_number(const NSDate *time) {
    if (!time) {
        time = now();
    }
    NSTimeInterval ti = [time timeIntervalSince1970];
    return [[NSNumber alloc] initWithDouble:ti];
}

static NSDate *number_time(const NSNumber *number) {
    NSTimeInterval ti = [number doubleValue];
    if (ti == 0) {
        return now();
    }
    return [[NSDate alloc] initWithTimeIntervalSince1970:ti];
}

@interface DIMEnvelope ()

@property (strong, nonatomic) MKMID *sender;
@property (strong, nonatomic) MKMID *receiver;

@property (strong, nonatomic) NSDate *time;

@end

@implementation DIMEnvelope

+ (instancetype)envelopeWithEnvelope:(id)env {
    if ([env isKindOfClass:[DIMEnvelope class]]) {
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

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    MKMID *from = nil;
    MKMID *to = nil;
    NSDate *time = nil;
    self = [self initWithSender:from receiver:to time:time];
    return self;
}

- (instancetype)initWithSender:(const MKMID *)from
                      receiver:(const MKMID *)to {
    NSDate *time = now();
    self = [self initWithSender:from receiver:to time:time];
    return self;
}

- (instancetype)initWithSender:(const MKMID *)from
                      receiver:(const MKMID *)to
                          time:(const NSDate *)time {
    NSDictionary *dict = @{@"sender"  :from,
                           @"receiver":to,
                           @"time"    :time_number(time),
                           };
    if (self = [super initWithDictionary:dict]) {
        _sender = [MKMID IDWithID:from];
        _receiver = [MKMID IDWithID:to];
        _time = [time copy];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        dict = _storeDictionary;
        
        // sender
        NSString *from = [dict objectForKey:@"sender"];
        _sender = [MKMID IDWithID:from];
        
        // receiver
        NSString *to = [dict objectForKey:@"receiver"];
        _receiver = [MKMID IDWithID:to];
        
        // time
        NSNumber *time = [dict objectForKey:@"time"];
        _time = number_time(time);
    }
    return self;
}

@end
