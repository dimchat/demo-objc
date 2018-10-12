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

@class MKMID;

@interface MKMUser : MKMAccount {
    
    NSMutableArray<const MKMID *> *_contacts;
}

@property (readonly, strong, nonatomic) NSArray<const MKMID *> *contacts;

@property (strong, nonatomic) MKMPrivateKey *privateKey;

// contacts
- (BOOL)addContact:(MKMID *)ID;
- (BOOL)containsContact:(const MKMID *)ID;
- (void)removeContact:(const MKMID *)ID;

- (BOOL)matchPrivateKey:(const MKMPrivateKey *)SK;

@end

NS_ASSUME_NONNULL_END
