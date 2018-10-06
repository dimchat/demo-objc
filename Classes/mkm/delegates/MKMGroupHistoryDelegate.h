//
//  MKMGroupHistoryDelegate.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "MKMSocialEntityHistoryDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMGroupHistoryDelegate : MKMSocialEntityHistoryDelegate

/**
 *  Permissions Table:
 *                       Founder Owner Admin Member Others
 *      1. found/create   YES     -     -     -      -
 *      2. abdicate       -       YES   -     -      -
 *      3. name/setName   -       YES   YES   YES    -
 *      4. invite         -       YES   YES   YES    -
 *      5. expel          -       YES   YES   NO     -
 *      6. join           -       -     -     -      YES
 *      7. quit           -       NO    NO    YES    -
 *      8. hire           -       YES   NO    NO     -
 *      9. fire           -       YES   NO    NO     -
 *     10. resign         -       -     YES   -      -
 *
 *      no one can expel itself;
 *      only the owner can hire/fire admin;
 *      owner must abdicate before quit;
 *      admin must be fired/resigned before quit.
 */

@end

NS_ASSUME_NONNULL_END
