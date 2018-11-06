//
//  DIMKeyStore.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

#define DIM_KEYSTORE_CONTACTS_FILENAME @"keystore_contacts.plist"
#define DIM_KEYSTORE_GROUPS_FILENAME   @"keystore_groups.plist"

@interface DIMKeyStore : NSObject

/**
 Current User
 */
@property (strong, nonatomic) MKMID *currentUser;

+ (instancetype)sharedInstance;

/**
 Persistent save cipher keys from contacts/group.members if changed

 @return YES when changed, or NO for nothing changed
 */
- (BOOL)flush;

#pragma mark - Cipher key to encpryt message for contact

/**
 Get a cipher key to encrypt message for a friend

 @param ID - friend
 @return passphrase
 */
- (MKMSymmetricKey *)cipherKeyForContact:(const MKMID *)ID;

/**
 Save the cipher key for the friend

 @param key - passphrase
 @param ID - friend
 */
- (void)setCipherKey:(MKMSymmetricKey *)key
          forContact:(const MKMID *)ID;

#pragma mark - Cipher key from contact to decrypt message

/**
 Get a cipher key from a friend to decrypt message

 @param ID - friend
 @return passphrase
 */
- (MKMSymmetricKey *)cipherKeyFromContact:(const MKMID *)ID;

/**
 Save the cipher key from the friend

 @param key - passphrase
 @param ID - friend
 */
- (void)setCipherKey:(MKMSymmetricKey *)key
         fromContact:(const MKMID *)ID;

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
