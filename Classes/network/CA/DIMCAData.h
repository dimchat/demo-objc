//
//  DIMCAData.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class DIMCASubject;
@class DIMCAValidity;

@interface DIMCAData : DIMDictionary

@property (strong, nonatomic) DIMCASubject *issuer; // issuer DN

@property (strong, nonatomic) DIMCAValidity *validity;

@property (strong, nonatomic) DIMCASubject *subject; // the CA owner
@property (strong, nonatomic) DIMPublicKey *publicKey; // owner's PK

+ (instancetype)dataWithData:(id)data;

@end

NS_ASSUME_NONNULL_END
