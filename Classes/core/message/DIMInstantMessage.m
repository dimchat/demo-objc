//
//  DIMInstantMessage.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMEnvelope.h"
#import "DIMMessageContent.h"

#import "DIMInstantMessage.h"

static NSDate *now() {
    return [[NSDate alloc] init];
}

//static NSNumber *time_number(const NSDate *time) {
//    if (!time) {
//        time = now();
//    }
//    NSTimeInterval ti = [time timeIntervalSince1970];
//    return [NSNumber numberWithDouble:ti];
//}

static NSDate *number_time(const NSNumber *number) {
    NSTimeInterval ti = [number doubleValue];
    if (ti == 0) {
        return now();
    }
    return [[NSDate alloc] initWithTimeIntervalSince1970:ti];
}

@interface DIMInstantMessage ()

@property (strong, nonatomic) DIMEnvelope *envelope;
@property (strong, nonatomic) DIMMessageContent *content;

@end

@implementation DIMInstantMessage

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    DIMMessageContent *content = nil;
    DIMEnvelope *env = nil;
    self = [self initWithContent:content envelope:env];
    return self;
}

- (instancetype)initWithContent:(const DIMMessageContent *)content
                         sender:(const MKMID *)from
                       receiver:(const MKMID *)to
                           time:(const NSDate *)time {
    DIMEnvelope *env;
    env = [[DIMEnvelope alloc] initWithSender:from
                                     receiver:to
                                         time:time];
    self = [self initWithContent:content envelope:env];
    return self;
}

- (instancetype)initWithContent:(const DIMMessageContent *)content
                       envelope:(const DIMEnvelope *)env {
    NSAssert(content, @"content cannot be empty");
    NSAssert(env, @"envelope cannot be empty");
    NSMutableDictionary *mDict;
    mDict = [[NSMutableDictionary alloc] initWithDictionary:(id)env];
    [mDict setObject:content forKey:@"content"];
    
    if (self = [super initWithDictionary:mDict]) {
        _envelope = [env copy];
        _content = [content copy];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
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
        self.envelope = env;
        
        // content
        id content = [dict objectForKey:@"content"];
        self.content = [DIMMessageContent contentWithContent:content];
    }
    return self;
}

@end
