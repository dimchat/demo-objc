//
//  MKMID.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

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

@property (readonly, strong, nonatomic) NSString *name;
@property (readonly, strong, nonatomic) MKMAddress *address;

@property (readonly, nonatomic, getter=isValid) BOOL valid;

+ (instancetype)IDWithID:(id)ID;

/**
 Initialize an ID from string

 @param aString - string form "name@address"
 @return ID object
 */
- (instancetype)initWithString:(NSString *)aString;

- (instancetype)initWithName:(const NSString *)seed
                     address:(const MKMAddress *)addr;

@end

NS_ASSUME_NONNULL_END
