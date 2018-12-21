//
//  DKDMessageContent+Quote.m
//  DaoKeDao
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessageContent+Text.h"

#import "DKDMessageContent+Quote.h"

@interface DKDMessageContent (Hacking)

@property (nonatomic) DKDMessageType type;

@end

@implementation DKDMessageContent (Quote)

- (instancetype)initWithText:(const NSString *)text
                       quote:(NSUInteger)sn {
    if (self = [self initWithText:text]) {
        // type
        self.type = DKDMessageType_Quote;
        
        // quote
        NSAssert(sn != 0, @"serial number cannot be ZERO");
        [_storeDictionary setObject:@(sn) forKey:@"quote"];
    }
    return self;
}

- (NSUInteger)quoteNumber {
    NSNumber *sn = [_storeDictionary objectForKey:@"quote"];
    return [sn unsignedIntegerValue];
}

@end
