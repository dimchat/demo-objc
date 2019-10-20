//
//  DKDInstantMessage+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/10/21.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMReceiptCommand.h"

#import "DKDInstantMessage+Extension.h"

@implementation DKDInstantMessage (Extension)

- (DIMMessageState)state {
    NSNumber *number = [_storeDictionary objectForKey:@"state"];
    return [number unsignedIntegerValue];
}

- (void)setState:(DIMMessageState)state {
    [_storeDictionary setObject:@(state) forKey:@"state"];
}

- (NSString *)error {
    return [_storeDictionary objectForKey:@"error"];
}

- (void)setError:(NSString *)error {
    if (error) {
        [_storeDictionary setObject:error forKey:@"error"];
    } else {
        [_storeDictionary removeObjectForKey:@"error"];
    }
}

- (BOOL)matchReceipt:(DIMReceiptCommand *)cmd {
    
    DIMContent *content = self.content;
    
    // check signature
    NSString *sig1 = [cmd objectForKey:@"signature"];
    NSString *sig2 = [self objectForKey:@"signature"];
    if (sig1.length >= 8 && sig2.length >= 8) {
        // if contains signature, check it
        sig1 = [sig1 substringToIndex:8];
        sig2 = [sig2 substringToIndex:8];
        return [sig1 isEqualToString:sig2];
    }
    
    // check envelope
    DIMEnvelope *env1 = cmd.envelope;
    DIMEnvelope *env2 = self.envelope;
    if (env1) {
        // if contains envelope, check it
        return [env1 isEqual:env2];
    }
    
    // check serial number
    // (only the original message's receiver can know this number)
    return cmd.serialNumber == content.serialNumber;
}

@end
