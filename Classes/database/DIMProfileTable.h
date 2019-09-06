//
//  DIMProfileTable.h
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMProfileTable : DIMStorage

- (nullable DIMProfile *)profileForID:(DIMID *)ID;

- (BOOL)saveProfile:(DIMProfile *)profile;

@end

NS_ASSUME_NONNULL_END
