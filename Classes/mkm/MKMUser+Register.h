//
//  MKMUser+Register.h
//  iChat
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMUser (Register)

/**
 Create a new account
 
 @param seed - username
 @param PK - public key
 @param SK - private key
 @return Account object
 */
+ (MKMUser *)registerWithName:(const NSString *)seed
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
