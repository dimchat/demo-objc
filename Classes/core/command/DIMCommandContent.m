//
//  DIMCommandContent.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCommandContent.h"

@implementation DIMCommandContent

+ (instancetype)commandWithCommand:(id)cmd {
    if ([cmd isKindOfClass:[DIMCommandContent class]]) {
        return cmd;
    } else if ([cmd isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:cmd];
    } else if ([cmd isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:cmd];
    } else {
        NSAssert(!cmd, @"unexpected command content: %@", cmd);
        return nil;
    }
}

@end
