//
//  DIMKeyStore.h
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMKeyStore : NSObject

+ (instancetype)sharedInstance;

/**
 Persistent save cipher keys from contacts/group.members if changed

 @return YES when changed, or NO for nothing changed
 */
- (BOOL)flush;

#pragma mark - Cipher key to encpryt message for contact

/**
 Get a cipher key to encrypt message for a friend

 @param contact - friend
 @return passphrase
 */
- (MKMSymmetricKey *)cipherKeyForContact:(const MKMContact *)contact;

/**
 Save the cipher key for the friend

 @param key - passphrase
 @param contact - friend
 */
- (void)setCipherKey:(MKMSymmetricKey *)key
          forContact:(const MKMContact *)contact;

#pragma mark - Cipher key from contact to decrypt message

/**
 Get a cipher key from a friend to decrypt message

 @param contact - friend
 @return passphrase
 */
- (MKMSymmetricKey *)cipherKeyFromContact:(const MKMContact *)contact;

/**
 Save the cipher key from the friend

 @param key - passphrase
 @param contact - friend
 */
- (void)setCipherKey:(MKMSymmetricKey *)key
         fromContact:(const MKMContact *)contact;

#pragma mark - Cipher key to encrypt message for all group members

/**
 Get a cipher key to encrypt message for all members in a group

 @param group - group
 @return passphrase
 */
- (MKMSymmetricKey *)cipherKeyForGroup:(const MKMGroup *)group;

/**
 Save the cipher key for all members in the group

 @param key - passphrase
 @param group - group
 */
- (void)setCipherKey:(MKMSymmetricKey *)key
            forGroup:(const MKMGroup *)group;

#pragma mark - Cipher key from a member in the group to decrypt message

/**
 Get a cipher key from a group member to decrypt message

 @param member - group.member
 @param group - group
 @return passphrase
 */
- (MKMSymmetricKey *)cipherKeyFromMember:(const MKMEntity *)member
                                 inGroup:(const MKMGroup *)group;

/**
 Save the cipher key from the group member

 @param key - passphrase
 @param member - group.member
 @param group - group
 */
- (void)setCipherKey:(MKMSymmetricKey *)key
          fromMember:(const MKMEntity *)member
             inGroup:(const MKMGroup *)group;

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
