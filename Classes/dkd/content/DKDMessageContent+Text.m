//
//  DKDMessageContent+Text.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessageContent+Text.h"

@implementation DKDMessageContent (Text)

- (instancetype)initWithText:(const NSString *)text {
    NSAssert(text, @"text cannot be empty");
    if (self = [self initWithType:DKDMessageType_Text]) {
        // text
        if (text) {
            [_storeDictionary setObject:text forKey:@"text"];
        }
    }
    return self;
}

- (NSString *)text {
    return [_storeDictionary objectForKey:@"text"];
}

@end
