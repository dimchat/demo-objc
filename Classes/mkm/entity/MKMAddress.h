//
//  MKMAddress.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMString.h"

NS_ASSUME_NONNULL_BEGIN

#define MKMAddressDefaultVersion 0x01

typedef NS_ENUM(UInt8, MKMNetworkID) {
    // Network_BitCoin = 0x00,
    MKMNetwork_Main    = 0x08,  // 0000 1000
    MKMNetwork_Group   = 0x10,  // 0001 0000
    MKMNetwork_Moments = 0x20,  // 0010 0000
};

/**
 *  Address like BitCoin
 *
 *      data format: "network+hash+checkcode"
 *          network   -- 1 byte
 *          hash      -- 20 bytes
 *          checkcode -- 4 bytes
 *
 *      algorithm:
 *          CT   = sign(seed, SK);
 *          hash = ripemd160(sha256(CT));
 *          code = sha256(sha256(network+hash)).prefix(4)
 *          addr = base58(network+hash+check)
 */
@interface MKMAddress : MKMString

@property (readonly, nonatomic) MKMNetworkID network; // Network ID
@property (readonly, nonatomic) UInt32 code; // check code

@property (readonly, nonatomic) BOOL isValid;

+ (instancetype)addressWithAddress:(id)addr;

/**
 Copy address data

 @param aString - Encoded address string
 @return Address object
 */
- (instancetype)initWithString:(NSString *)aString;

/**
 Generate address with fingerprint and network ID

 @param CT - fingerprint = sign(seed, PK)
 @param type - network ID
 @param metaVersion - algorithm version
 @return Address object
 */
- (instancetype)initWithFingerprint:(const NSData *)CT
                            network:(MKMNetworkID)type
                            version:(NSUInteger)metaVersion;

@end

NS_ASSUME_NONNULL_END
