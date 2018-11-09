//
//  MKMUser+History.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMUser.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMHistoryBlock;

@interface MKMUser (History)

/**
 Create a new account
 
 @param seed - username
 @param SK - private key
 @param PK - public key, it will get from SK if empty
 @return User(Account)
 */
+ (instancetype)registerWithName:(const NSString *)seed
                      privateKey:(const MKMPrivateKey *)SK
                       publicKey:(nullable const MKMPublicKey *)PK;

/**
 Delete the account, FOREVER!
 
 @param lastWords - a message to the world
 @param SK - private key
 */
- (MKMHistoryBlock *)suicideWithMessage:(const NSString *)lastWords
                             privateKey:(const MKMPrivateKey *)SK;

@end

NS_ASSUME_NONNULL_END
