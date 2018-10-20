//
//  DIMSystemCommand.m
//  DIM
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMEnvelope.h"
#import "DIMCommandContent.h"

#import "DIMSystemCommand.h"

@interface DIMSystemCommand ()

@property (strong, nonatomic) DIMCommandContent *command;

@end

@implementation DIMSystemCommand

- (instancetype)initWithEnvelope:(const DIMEnvelope *)env {
    NSAssert(false, @"DON'T call me");
    DIMCommandContent *cmd = nil;
    self = [self initWithCommand:cmd envelope:env];
    return self;
}

- (instancetype)initWithCommand:(const DIMCommandContent *)cmd
                         sender:(const MKMID *)from
                       receiver:(const MKMID *)to
                           time:(const NSDate *)time {
    DIMEnvelope *env = [[DIMEnvelope alloc] initWithSender:from
                                                  receiver:to
                                                      time:time];
    self = [self initWithCommand:cmd envelope:env];
    return self;
}

/* designated initializer */
- (instancetype)initWithCommand:(const DIMCommandContent *)cmd
                       envelope:(const DIMEnvelope *)env {
    NSAssert(cmd, @"command cannot be empty");
    NSAssert(env, @"envelope cannot be empty");
    if (self = [super initWithEnvelope:env]) {
        // command
        _command = [DIMCommandContent commandWithCommand:cmd];
        [_storeDictionary setObject:_command forKey:@"command"];
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        dict = _storeDictionary;
        
        // command
        id cmd = [dict objectForKey:@"command"];
        _command = [DIMCommandContent commandWithCommand:cmd];
    }
    return self;
}

@end
