//
//  DIMMessageContent+Text.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessageContent+Text.h"

@implementation DIMMessageContent (Text)

- (instancetype)initWithText:(const NSString *)text {
    if (self = [self initWithType:DIMMessageType_Text]) {
        // text
        NSAssert(text, @"text cannot be empty");
        [_storeDictionary setObject:text forKey:@"text"];
    }
    return self;
}

- (NSString *)text {
    return [_storeDictionary objectForKey:@"text"];
}

@end
