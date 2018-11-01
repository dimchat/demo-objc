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

@interface MKMUser : MKMAccount {
    
    MKMPrivateKey *_privateKey;
    
    NSMutableArray<const MKMID *> *_contacts;
}

@property (strong, nonatomic) MKMPrivateKey *privateKey;

@property (readonly, strong, nonatomic) NSArray<const MKMID *> *contacts;

// contacts
- (BOOL)addContact:(MKMID *)ID;
- (BOOL)containsContact:(const MKMID *)ID;
- (void)removeContact:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
