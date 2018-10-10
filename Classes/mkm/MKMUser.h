//
//  MKMUser.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAccount.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPublicKey;
@class MKMPrivateKey;

@class MKMID;
@class MKMMeta;
@class MKMContact;

@class MKMHistoryRecord;

@interface MKMUser : MKMAccount {
    
    NSMutableDictionary<const MKMID *, MKMContact *> *_contacts;
}

@property (readonly, strong, nonatomic) const NSDictionary *contacts;

@property (readonly, strong, nonatomic) const MKMPrivateKey *privateKey;

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta
NS_DESIGNATED_INITIALIZER;

- (BOOL)addContact:(MKMContact *)contact;
- (MKMContact *)getContactByID:(const MKMID *)ID;

- (BOOL)checkPrivateKey:(const MKMPrivateKey *)SK;

@end

@interface MKMUser (History)

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
