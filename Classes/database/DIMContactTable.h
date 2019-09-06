//
//  DIMContactTable.h
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMContactTable : DIMStorage

- (nullable NSArray<DIMID *> *)contactsOfUser:(DIMID *)user;
- (BOOL)saveContacts:(NSArray *)contacts user:(DIMID *)user;

@end

NS_ASSUME_NONNULL_END
