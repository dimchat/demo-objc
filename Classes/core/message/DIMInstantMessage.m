//
//  DIMInstantMessage.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMMessageContent.h"

#import "DIMInstantMessage.h"

static NSDate *now() {
    return [[NSDate alloc] init];
}

static NSDate *make_time(const NSTimeInterval ti) {
    return [[NSDate alloc] initWithTimeIntervalSince1970:ti];
}

@interface DIMInstantMessage ()

@property (strong, nonatomic) const MKMID *sender;
@property (strong, nonatomic) const MKMID *receiver;
@property (strong, nonatomic) const NSDate *time;

@property (strong, nonatomic) const DIMMessageContent *content;

@end

@implementation DIMInstantMessage

- (instancetype)init {
    DIMMessageContent *content = nil;
    MKMID *from = nil;
    MKMID *to = nil;
    self = [self initWithContent:content
                          sender:from
                        receiver:to];
    return self;
}

- (instancetype)initWithContent:(const DIMMessageContent *)content
                         sender:(const MKMID *)from
                       receiver:(const MKMID *)to {
    NSAssert(content, @"conntent cannot be empty");
    NSDate *time = now();
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:4];
    if (from) {
        [mDict setObject:from forKey:@"sender"];
    }
    if (to) {
        [mDict setObject:to forKey:@"receiver"];
    }
    //if (time) {
        [mDict setObject:time forKey:@"time"];
    //}
    if (content) {
        [mDict setObject:content forKey:@"content"];
    }
    
    if (self = [super initWithDictionary:mDict]) {
        self.sender = from;
        self.receiver = to;
        self.time = time;
        self.content = content;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // sender
        id from = [dict objectForKey:@"sender"];
        self.sender = [MKMID IDWithID:from];
        
        // receiver
        id to = [dict objectForKey:@"receiver"];
        self.receiver = [MKMID IDWithID:to];
        
        // time
        NSNumber *ti = [dict objectForKey:@"time"];
        if (ti) {
            self.time = make_time([ti unsignedIntegerValue]);
        } else {
            self.time = now();
        }
        
        // content
        id content = [dict objectForKey:@"content"];
        self.content = [DIMMessageContent contentWithContent:content];
    }
    return self;
}

@end
