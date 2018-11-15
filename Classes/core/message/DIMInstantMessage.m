//
//  DIMInstantMessage.m
//  DIMCore
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMEnvelope.h"
#import "DIMMessageContent.h"

#import "DIMInstantMessage.h"

@interface DIMInstantMessage ()

@property (strong, nonatomic) DIMMessageContent *content;

@end

@implementation DIMInstantMessage

- (instancetype)initWithEnvelope:(const DIMEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    DIMMessageContent *content = nil;
    self = [self initWithContent:content envelope:env];
    return self;
}

- (instancetype)initWithContent:(const DIMMessageContent *)content
                         sender:(const MKMID *)from
                       receiver:(const MKMID *)to
                           time:(nullable const NSDate *)time {
    DIMEnvelope *env = [[DIMEnvelope alloc] initWithSender:from
                                                  receiver:to
                                                      time:time];
    self = [self initWithContent:content envelope:env];
    return self;
}

/* designated initializer */
- (instancetype)initWithContent:(const DIMMessageContent *)content
                       envelope:(const DIMEnvelope *)env {
    NSAssert(content, @"content cannot be empty");
    NSAssert(env, @"envelope cannot be empty");
    if (self = [super initWithEnvelope:env]) {
        // content
        _content = [content copy];
        [_storeDictionary setObject:_content forKey:@"content"];
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // content
        _content = nil; // lazy
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    DIMInstantMessage *iMsg = [super copyWithZone:zone];
    if (iMsg) {
        iMsg.content = _content;
    }
    return iMsg;
}

- (DIMMessageContent *)content {
    if (!_content) {
        id content = [_storeDictionary objectForKey:@"content"];
        _content = [DIMMessageContent contentWithContent:content];
    }
    return _content;
}

@end
