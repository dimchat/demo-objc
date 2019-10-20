//
//  DIMReceiptCommand.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Compare.h"
#import "NSDate+Timestamp.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "DIMReceiptCommand.h"

@implementation DIMReceiptCommand

- (instancetype)initWithMessage:(NSString *)message {
    if (self = [self initWithCommand:DIMSystemCommand_Receipt]) {
        // message
        if (message) {
            [_storeDictionary setObject:message forKey:@"message"];
        }
    }
    return self;
}

- (NSString *)message {
    return [_storeDictionary objectForKey:@"message"];
}

- (nullable DIMEnvelope *)envelope {
    NSString *sender = [_storeDictionary objectForKey:@"sender"];
    NSString *receiver = [_storeDictionary objectForKey:@"receiver"];
    if (sender && receiver) {
        NSNumber *number = [_storeDictionary objectForKey:@"time"];
        NSDate *time = NSDateFromNumber(number);
        return DKDEnvelopeCreate(sender, receiver, time);
    } else {
        return nil;
    }
}

- (void)setEnvelope:(DIMEnvelope *)envelope {
    if (envelope) {
        NSNumber *timestamp = NSNumberFromDate(envelope.time);
        [_storeDictionary setObject:envelope.sender forKey:@"sender"];
        [_storeDictionary setObject:envelope.receiver forKey:@"receiver"];
        [_storeDictionary setObject:timestamp forKey:@"time"];
    } else {
        [_storeDictionary removeObjectForKey:@"sender"];
        [_storeDictionary removeObjectForKey:@"receiver"];
        [_storeDictionary removeObjectForKey:@"time"];
    }
}

- (NSData *)signature {
    NSString *CT = [_storeDictionary objectForKey:@"signature"];
    return [CT base64Decode];
}

- (void)setSignature:(NSData *)signature {
    if (signature) {
        [_storeDictionary setObject:[signature base64Encode] forKey:@"signature"];
    } else {
        [_storeDictionary removeObjectForKey:@"signature"];
    }
}

@end
