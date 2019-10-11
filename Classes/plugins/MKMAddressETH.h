//
//  MKMAddressETH.h
//  DIMClient
//
//  Created by Albert Moky on 2019/7/16.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

NS_ASSUME_NONNULL_BEGIN

#define MKMAddressBTC MKMAddressDefault

@interface MKMAddressETH : MKMAddress

/**
 *  Generate address with key data and network ID
 *
 * @param key - public key data
 * @param type - network ID
 * @return Address object
 */
+ (instancetype)generateWithData:(NSData *)key network:(MKMNetworkType)type;

@end

NS_ASSUME_NONNULL_END
