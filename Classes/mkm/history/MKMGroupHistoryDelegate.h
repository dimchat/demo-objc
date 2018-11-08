//
//  MKMGroupHistoryDelegate.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntityHistoryDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMGroupHistoryDelegate : MKMEntityHistoryDelegate

/**
 *  Permissions Table:
 *
 *  /=============+=========+=============+=============+=======\
 *  |             | Founder |    Owner    |    Member   | Other |
 *  |             |         | Wai Nor Fre | Wai Nor Fre |       |
 *  +=============+=========+=============+=============+=======+
 *  | 1. found    |  YES    |  -   -   -  |  -   -   -  |  -    |
 *  | 2. abdicate |   -     |  NO YES  NO |  -   -   -  |  -    |
 *  +-------------+---------+-------------+-------------+-------+
 *  | 3. invite   |   -     | YES YES YES |  NO YES  NO |  -    |
 *  | 4. expel    |   -     |  NO YES YES |  NO  NO  NO |  -    |
 *  | 5. join     |   -     |  -   -   -  |  -   -   -  | YES   |
 *  | 6. quit     |   -     |  NO  NO  NO | YES YES  -  |  -    |
 *  +-------------+---------+-------------+-------------+-------+
 *  | 7. speak    |   -     | YES YES YES | YES YES  NO |  NO   |
 *  | 8. history  |  1st    |  NO YES YES |  NO  NO  NO |  NO   |
 *  \=============+=========+=============+=============+=======/
 *                                (Wai: Waiting, Nor: Normal, Fre: Freezing)
 *
 *  Role Transition Model:
 *
 *        Founder
 *           |      (Freezing) ----+         (Freezing) ------+
 *           |        /            |           /              |
 *           V       /             V          /               V
 *        Owner (Normal)          Member (Normal)           Other User
 *                   \             |          \               |
 *                    \            |           \              |
 *                  (Waiting) <----+         (Waiting) <------+
 *
 *      Waiting Owner  == Normal Member (abdicate)
 *      Freezing Owner ~= Normal Member (write history)
 *      Waiting Member == Normal Member (invite/join)
 *      Freezing Member ~= Others       (expel/quit)
 *
 *  Other rules:
 *      no one can expel itself;
 *      owner must abdicate before quit.
 */

@end

NS_ASSUME_NONNULL_END
