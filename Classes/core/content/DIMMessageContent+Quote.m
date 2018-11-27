//
//  DIMMessageContent+Quote.m
//  DIMCore
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMMessageContent+Text.h"

#import "DIMMessageContent+Quote.h"

@interface DIMMessageContent (Hacking)

@property (nonatomic) DIMMessageType type;

@end

@implementation DIMMessageContent (Quote)

- (instancetype)initWithText:(const NSString *)text
                       quote:(NSUInteger)sn {
    if (self = [self initWithText:text]) {
        // type
        self.type = DIMMessageType_Quote;
        
        // quote
        [_storeDictionary setObject:@(sn) forKey:@"quote"];
    }
    return self;
}

- (NSUInteger)quoteNumber {
    NSNumber *sn = [_storeDictionary objectForKey:@"quote"];
    return sn.unsignedIntegerValue;
}

@end
