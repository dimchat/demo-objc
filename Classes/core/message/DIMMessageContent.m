//
//  DIMMessageContent.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMMessageContent.h"

@implementation DIMMessageContent

+ (instancetype)contentWithContent:(id)content {
    if ([content isKindOfClass:[DIMMessageContent class]]) {
        return content;
    } else if ([content isKindOfClass:[NSDictionary class]]) {
        return [[[self class] alloc] initWithDictionary:content];
    } else if ([content isKindOfClass:[NSString class]]) {
        return [[[self class] alloc] initWithJSONString:content];
    } else {
        NSAssert(!content, @"unexpected message content: %@", content);
        return content;
    }
}

@end
