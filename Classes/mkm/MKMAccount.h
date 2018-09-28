//
//  MKMAccount.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKMEntity.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPublicKey;
@class MKMPrivateKey;

typedef NS_ENUM(SInt32, MKMAccountStatus) {
    MKMAccountStatusInitialized = 0,
    MKMAccountStatusRegistered = 1,
    MKMAccountStatusDead = -1,
};

@interface MKMAccount : MKMEntity

@property (readonly, strong, nonatomic) const MKMPublicKey *publicKey;

@property (readonly, nonatomic) NSUInteger number;
@property (readonly, nonatomic) MKMAccountStatus status;

/**
 Create a new account

 @param seed - username
 @param PK - public key
 @param SK - private key
 @return Account object
 */
+ (instancetype)registerWithName:(const NSString *)seed
                       publicKey:(const MKMPublicKey *)PK
                      privateKey:(const MKMPrivateKey *)SK;

/**
 Delete the account, FOREVER!

 @param lastWords - a message to the world
 @param SK - private key
 */
- (MKMHistoryRecord *)suicideWithMessage:(const NSString *)lastWords
                              privateKey:(const MKMPrivateKey *)SK;

@end

NS_ASSUME_NONNULL_END
