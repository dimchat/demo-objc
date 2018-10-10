//
//  MKMSocialEntityHistoryDelegate.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntityHistoryDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMSocialEntityHistoryDelegate : MKMEntityHistoryDelegate

/**
 *  Permissions Table:
 *                       Founder Owner Member Others
 *      1. found/create   YES     -     -      -
 *      2. abdicate       -       YES   -      -
 *      3. name/setName   -       YES   YES    -
 *      4. invite         -       YES   YES    -
 *      5. expel          -       YES   NO     -
 *      6. join           -       -     -      YES
 *      7. quit           -       NO    YES    -
 *
 *      no one can expel itself;
 *      owner must abdicate before quit.
 */

@end

NS_ASSUME_NONNULL_END
