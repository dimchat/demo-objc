//
//  MKMAddress+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/7/16.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "MKMAddress+Extension.h"

@interface MKMAddress (Hacking)

@property (nonatomic) MKMNetworkType network; // Network ID
@property (nonatomic) UInt32 code;            // Check Code

@end

@implementation MKMAddressETH

- (instancetype)initWithString:(NSString *)aString {
    if (self = [super initWithString:aString]) {
        // TODO: Parse string with ETH address format
        @throw [NSException exceptionWithName:@"ETH Address"
                                       reason:@"not implement" userInfo:nil];
    }
    return self;
}

/**
 *  ETH address algorithm:
 */
- (instancetype)initWithData:(NSData *)key
                     network:(MKMNetworkType)type {
    NSString *string = nil;
    UInt32 code = 0;
    
    // TODO: create ETH address with key data
    
    if (self = [super initWithString:string]) {
        self.network = type;
        self.code = code;
    }
    return self;
}

+ (instancetype)generateWithData:(NSData *)key network:(MKMNetworkType)type {
    return [[self alloc] initWithData:key network:type];
}

@end
