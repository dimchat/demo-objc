//
//  MKMImmortals.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

//#import "MKMUser.h"
//#import "MKMContact.h"
//#import "MKMProfile.h"
#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Create two immortal accounts for test:
 *
 *      1. Immortal Hulk
 *      2. Monkey King
 */
@interface MKMImmortals : NSObject <MKMUserDelegate,
                                    MKMContactDelegate,
                                    MKMEntityDataSource,
                                    MKMProfileDataSource>

@end

NS_ASSUME_NONNULL_END
