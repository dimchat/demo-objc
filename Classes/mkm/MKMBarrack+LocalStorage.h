//
//  MKMBarrack+LocalStorage.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMBarrack.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMBarrack (LocalStorage)

- (MKMMeta *)loadMetaForEntityID:(const MKMID *)ID;

- (BOOL)saveMeta:(const MKMMeta *)meta forEntityID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
