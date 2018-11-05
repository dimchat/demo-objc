//
//  MKMAccount.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntity.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPublicKey;

typedef NS_ENUM(SInt32, MKMAccountStatus) {
    MKMAccountStatusInitialized = 0,
    MKMAccountStatusRegistered = 1,
    MKMAccountStatusDead = -1,
};

@interface MKMAccount : MKMEntity {
    
    // public key
    MKMPublicKey *_publicKey;
    
    // account status (parse history to update)
    MKMAccountStatus _status;
}

@property (readonly, strong, nonatomic) MKMPublicKey *publicKey;

@property (nonatomic) MKMAccountStatus status;

- (instancetype)initWithID:(const MKMID *)ID
                 publicKey:(const MKMPublicKey *)PK
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
