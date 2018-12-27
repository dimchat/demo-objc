//
//  DKDMessageContent+Command.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/11/10.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessageContent+Command.h"

@implementation DKDMessageContent (Command)

- (instancetype)initWithCommand:(const NSString *)cmd {
    NSAssert(cmd, @"command name cannot be empty");
    if (self = [self initWithType:DKDMessageType_Command]) {
        // command
        if (cmd) {
            [_storeDictionary setObject:cmd forKey:@"command"];
        }
    }
    return self;
}

- (NSString *)command {
    return [_storeDictionary objectForKey:@"command"];
}

@end
