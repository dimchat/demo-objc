//
//  DIMMetaTable.h
//  DIMClient
//
//  Created by Albert Moky on 2019/9/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMMetaTable : DIMStorage

- (nullable DIMMeta *)metaForID:(DIMID *)ID;

- (BOOL)saveMeta:(DIMMeta *)meta forID:(DIMID *)ID;

@end

@interface DIMMetaTable (ID)

- (nullable DIMID *)IDWithAddress:(DIMAddress *)address;

@end

NS_ASSUME_NONNULL_END
