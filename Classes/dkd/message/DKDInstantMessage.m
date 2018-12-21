//
//  DKDInstantMessage.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDEnvelope.h"
#import "DKDMessageContent.h"

#import "DKDInstantMessage.h"

@interface DKDInstantMessage ()

@property (strong, nonatomic) DKDMessageContent *content;

@end

@implementation DKDInstantMessage

- (instancetype)initWithEnvelope:(const DKDEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    DKDMessageContent *content = nil;
    self = [self initWithContent:content envelope:env];
    return self;
}

- (instancetype)initWithContent:(const DKDMessageContent *)content
                         sender:(const MKMID *)from
                       receiver:(const MKMID *)to
                           time:(nullable const NSDate *)time {
    DKDEnvelope *env = [[DKDEnvelope alloc] initWithSender:from
                                                  receiver:to
                                                      time:time];
    self = [self initWithContent:content envelope:env];
    return self;
}

/* designated initializer */
- (instancetype)initWithContent:(const DKDMessageContent *)content
                       envelope:(const DKDEnvelope *)env {
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
    DKDInstantMessage *iMsg = [super copyWithZone:zone];
    if (iMsg) {
        iMsg.content = _content;
    }
    return iMsg;
}

- (DKDMessageContent *)content {
    if (!_content) {
        id content = [_storeDictionary objectForKey:@"content"];
        _content = [DKDMessageContent contentWithContent:content];
    }
    return _content;
}

@end
