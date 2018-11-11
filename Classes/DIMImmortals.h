//
//  DIMImmortals.h
//  DIMC
//
//  Created by Albert Moky on 2018/11/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DimCore.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Create two immortal accounts for test:
 *
 *      1. Immortal Hulk
 *      2. Monkey King
 */
@interface DIMImmortals : NSObject <MKMUserDelegate,
                                    MKMContactDelegate,
                                    MKMEntityDataSource,
                                    MKMProfileDataSource>

@end

NS_ASSUME_NONNULL_END
