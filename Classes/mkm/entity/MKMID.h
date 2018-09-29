//
//  MKMID.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKMString.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPublicKey;
@class MKMAddress;
@class MKMMeta;

/**
 *  User/Group ID
 *
 *      data format: "name@address"
 */
@interface MKMID : MKMString

@property (readonly, strong, nonatomic) const NSString *name;
@property (readonly, strong, nonatomic) const MKMAddress *address;

@property (readonly, nonatomic) BOOL isValid;

@property (readonly, strong, nonatomic) const MKMPublicKey *publicKey;

- (instancetype)initWithString:(NSString *)aString;
- (instancetype)initWithName:(const NSString *)seed
                     address:(const MKMAddress *)addr;

/**
 *  Check ID with meta info, get PK while match
 *
 *      username == meta.username && address == meta.address
 */
- (BOOL)checkMeta:(const MKMMeta *)meta;

@end

NS_ASSUME_NONNULL_END
