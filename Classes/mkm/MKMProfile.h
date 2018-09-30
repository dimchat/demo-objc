//
//  MKMProfile.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMProfile : MKMDictionary

/**
 Profile fields that anyone can read
 */
@property (strong, nonatomic) NSMutableArray *publicFields;

/**
 Profile fields only the MKM network can read
 */
@property (strong, nonatomic) NSMutableArray *protectedFields;

/**
 Extra fields only the user itself can read
 */
@property (strong, nonatomic) NSMutableArray *privateFields;

- (instancetype)init;
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
