//
//  MKMUser.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAccount.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPrivateKey;
@class MKMContact;

typedef NSMutableArray<const MKMID *> MKMContactListM;
typedef NSArray<const MKMID *> MKMContactList;

@interface MKMUser : MKMAccount {
    
    MKMPrivateKey *_privateKey;
    
    MKMContactListM *_contacts;
}

@property (strong, nonatomic) MKMPrivateKey *privateKey;

@property (readonly, strong, nonatomic) MKMContactList *contacts;

// contacts
- (BOOL)addContact:(MKMID *)ID;
- (BOOL)containsContact:(const MKMID *)ID;
- (void)removeContact:(const MKMID *)ID;

@end

#pragma mark - User Delegate

@protocol MKMUserDataSource <NSObject>

- (NSInteger)numberOfContactsInUser:(const MKMUser *)usr;
- (MKMID *)user:(const MKMUser *)usr contactAtIndex:(NSInteger)index;

@end

@protocol MKMUserDelegate <NSObject>

/**
 User factory

 @param ID - user ID
 @return user
 */
- (MKMUser *)userWithID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
