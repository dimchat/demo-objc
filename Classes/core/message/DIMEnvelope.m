//
//  DIMEnvelope.m
//  DIM
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
    return [NSNumber numberWithDouble:ti];
}

static NSDate *number_time(const NSNumber *number) {
    NSTimeInterval ti = [number doubleValue];
    if (ti == 0) {
        return now();
    }
    return [[NSDate alloc] initWithTimeIntervalSince1970:ti];
}

@interface DIMEnvelope ()

@property (strong, nonatomic) const MKMID *sender;
@property (strong, nonatomic) const MKMID *receiver;

@property (strong, nonatomic) const NSDate *time;

@end

@implementation DIMEnvelope

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
    NSMutableDictionary *mDict;
    mDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    // sender
    if (from) {
        [mDict setObject:from forKey:@"sender"];
    }
    // receiver
    if (to) {
        [mDict setObject:to forKey:@"receiver"];
    }
    // time
    if (time) {
        [mDict setObject:time_number(time) forKey:@"time"];
    }
    
    if (self = [super initWithDictionary:mDict]) {
        self.sender = [MKMID IDWithID:from];
        self.receiver = [MKMID IDWithID:to];
        self.time = time;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // sender
        NSString *from = [dict objectForKey:@"sender"];
        self.sender = [MKMID IDWithID:from];
        // receiver
        NSString *to = [dict objectForKey:@"receiver"];
        self.receiver = [MKMID IDWithID:to];
        // time
        NSNumber *time = [dict objectForKey:@"time"];
        self.time = number_time(time);
    }
    return self;
}

@end
