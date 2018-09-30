//
//  MKMUser.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMAccount.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMID;
@class MKMContact;

@interface MKMUser : MKMAccount {
    
    const NSMutableDictionary *_contacts;
}

@property (strong, nonatomic) const NSString *name;
@property (nonatomic) const MKMGender gender;
@property (strong, nonatomic) const NSString *avatar; // URL

@property (readonly, strong, nonatomic) const NSDictionary *contacts;

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta
NS_DESIGNATED_INITIALIZER;

- (BOOL)addContact:(const MKMContact *)contact;
- (MKMContact *)getContactByID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
