//
//  MKMMeta+Extension.h
//  DIMClient
//
//  Created by Albert Moky on 2019/7/16.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Meta to build ID with BTC address
 *
 *  version:
 *      0x02 - BTC
 *      0x03 - ExBTC
 */
@interface MKMMetaBTC : MKMMeta

@end

/**
 *  Meta to build ID with ETH address
 *
 *  version:
 *      0x04 - ETH
 *      0x05 - ExETH
 */
@interface MKMMetaETH : MKMMeta

@end

NS_ASSUME_NONNULL_END
