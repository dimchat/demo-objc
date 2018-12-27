//
//  MKMUser+History.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMUser.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMRegisterInfo;
@class MKMHistoryBlock;

@interface MKMUser (History)

/**
 Create a new account
 
 @param seed - username
 @param SK - private key
 @param PK - public key, it will get from SK if empty
 @return RegisterInfo
 */
+ (MKMRegisterInfo *)registerWithName:(const NSString *)seed
                           privateKey:(const MKMPrivateKey *)SK
                            publicKey:(nullable const MKMPublicKey *)PK;

/**
 Create register record for the account

 @param hello - say hello to the world
 @return HistoryBlock
 */
- (MKMHistoryBlock *)registerWithMessage:(nullable const NSString *)hello;

/**
 Delete the account, FOREVER!
 
 @param lastWords - last message to the world
 @return HistoryBlock
 */
- (MKMHistoryBlock *)suicideWithMessage:(nullable const NSString *)lastWords;

@end

#pragma mark -

@interface MKMRegisterInfo : MKMDictionary

@property (strong, nonatomic) MKMPrivateKey *privateKey;
@property (strong, nonatomic) MKMPublicKey *publicKey;

@property (strong, nonatomic) MKMMeta *meta;
@property (strong, nonatomic) MKMID *ID;

@property (strong, nonatomic) MKMUser *user;

@end

NS_ASSUME_NONNULL_END
