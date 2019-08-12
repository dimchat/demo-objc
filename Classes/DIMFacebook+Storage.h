//
//  DIMFacebook+Storage.h
//  DIMClient
//
//  Created by Albert Moky on 2019/8/13.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMFacebook.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMFacebook (Storage)

// default "Documents/.mkm/{address}/meta.plist"
- (nullable DIMMeta *)loadMetaForID:(DIMID *)ID;

// default "Documents/.mkm/{address}/profile.plist"
- (nullable __kindof DIMProfile *)loadProfileForID:(DIMID *)ID;

// default "Documents/.mkm/{address}/contacts.plist"
- (nullable NSArray<DIMID *> *)loadContactsForUser:(DIMID *)user;

// default "Documents/.mkm/{address}/members.plist"
- (nullable NSArray<DIMID *> *)loadMembersForGroup:(DIMID *)group;

//----

- (BOOL)saveMembers:(NSArray *)members forGroup:(DIMGroup *)group;

@end

NS_ASSUME_NONNULL_END
