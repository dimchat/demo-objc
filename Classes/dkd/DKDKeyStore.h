//
//  DKDKeyStore.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

@interface DKDKeyStore : NSObject

/**
 Current User
 */
@property (strong, nonatomic) MKMUser *currentUser;

+ (instancetype)sharedInstance;

/**
 Persistent save cipher keys from accounts/group.members if changed

 @return YES when changed, or NO for nothing changed
 */
- (BOOL)flush;

/**
 Clear all keys in memory
 */
- (void)clearMemory;

#pragma mark - Cipher key to encpryt message for account(contact)

/**
 Get a cipher key to encrypt message for a friend(contact)

 @param ID - friend
 @return passphrase
 */
- (MKMSymmetricKey *)cipherKeyForAccount:(const MKMID *)ID;

/**
 Save the cipher key for the friend(contact)

 @param key - passphrase
 @param ID - friend
 */
- (void)setCipherKey:(MKMSymmetricKey *)key
          forAccount:(const MKMID *)ID;

#pragma mark - Cipher key from contact to decrypt message

/**
 Get a cipher key from a friend(contact) to decrypt message

 @param ID - friend
 @return passphrase
 */
- (MKMSymmetricKey *)cipherKeyFromAccount:(const MKMID *)ID;

/**
 Save the cipher key from the friend(contact)

 @param key - passphrase
 @param ID - friend
 */
- (void)setCipherKey:(MKMSymmetricKey *)key
         fromAccount:(const MKMID *)ID;

#pragma mark - Cipher key to encrypt message for all group members

/**
 Get a cipher key to encrypt message for all members in a group

 @param ID - group
 @return passphrase
 */
- (MKMSymmetricKey *)cipherKeyForGroup:(const MKMID *)ID;

/**
 Save the cipher key for all members in the group

 @param key - passphrase
 @param ID - group
 */
- (void)setCipherKey:(MKMSymmetricKey *)key
            forGroup:(const MKMID *)ID;

#pragma mark - Cipher key from a member in the group to decrypt message

/**
 Get a cipher key from a group member to decrypt message

 @param ID - group.member
 @param group - group
 @return passphrase
 */
- (MKMSymmetricKey *)cipherKeyFromMember:(const MKMID *)ID
                                 inGroup:(const MKMID *)group;

/**
 Save the cipher key from the group member

 @param key - passphrase
 @param ID - group.member
 @param group - group
 */
- (void)setCipherKey:(MKMSymmetricKey *)key
          fromMember:(const MKMID *)ID
             inGroup:(const MKMID *)group;

#pragma mark - Private key encrpyted by a password for user

/**
 Get encrypted SK for user to store elsewhere
 
 @param user - user
 @param PW - password to encrypt the SK
 @return KS
 */
- (NSData *)privateKeyStoredForUser:(const MKMUser *)user
                         passphrase:(const MKMSymmetricKey *)PW;

@end

NS_ASSUME_NONNULL_END
