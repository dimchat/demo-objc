//
//  DKDSecureMessage+Packing.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/12/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDSecureMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DKDSecureMessage (Packing)

/**
 *  Group ID
 *      when a group message was splitted/trimmed to a single message
 *      the 'receiver' will be changed to a member ID, and
 *      the group ID will be saved as 'group'.
 */
@property (strong, nonatomic, nullable) MKMID *group;

/**
 *  Split the group message to single person messages
 *
 *  @return SecureMessage
 */
- (NSArray<DKDSecureMessage *> *)split;

/**
 *  Trim the group message for a member
 *
 * @param member - group member ID
 * @return SecureMessage
 */
- (DKDSecureMessage *)trimForMember:(const MKMID *)member;

@end

NS_ASSUME_NONNULL_END
