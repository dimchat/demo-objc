//
//  DIMMessageContent+Command.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/10.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessageContent+Command.h"

@interface DIMMessageContent (Hacking)

@property (nonatomic) DIMMessageType type;

@end

@implementation DIMMessageContent (Command)

- (instancetype)initWithCommand:(const NSString *)cmd {
    if (self = [self init]) {
        // type
        self.type = DIMMessageType_Command;
        
        // command
        [_storeDictionary setObject:cmd forKey:@"command"];
    }
    return self;
}

- (NSString *)command {
    return [_storeDictionary objectForKey:@"command"];
}

@end
