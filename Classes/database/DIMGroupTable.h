//
//  DIMGroupTable.h
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMGroupTable : DIMStorage

- (nullable DIMID *)founderOfGroup:(DIMID *)group;

- (nullable DIMID *)ownerOfGroup:(DIMID *)group;

- (nullable NSArray<DIMID *> *)membersOfGroup:(DIMID *)group;

- (BOOL)saveMembers:(NSArray *)members group:(DIMID *)group;

@end

NS_ASSUME_NONNULL_END
