//
//  MKMMetaETH.m
//  DIMClient
//
//  Created by Albert Moky on 2019/7/16.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "MKMAddressETH.h"

#import "MKMMetaETH.h"

@implementation MKMMetaBTC

- (MKMAddress *)generateAddress:(MKMNetworkType)type {
    NSAssert(self.version & MKMMetaVersion_BTC, @"meta version error");
    NSData *data = self.key.data;
    // FIXME: pre-process key data
    return [MKMAddressBTC generateWithData:data network:type];
}

@end

@implementation MKMMetaETH

- (MKMAddress *)generateAddress:(MKMNetworkType)type {
    NSAssert(self.version & MKMMetaVersion_ETH, @"meta version error");
    NSData *data = self.key.data;
    // FIXME: pre-process key data
    return [MKMAddressETH generateWithData:data network:type];
}

@end
