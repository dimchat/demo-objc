//
//  MKMChatroomHistoryDelegate.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMGroupHistoryDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMChatroomHistoryDelegate : MKMGroupHistoryDelegate

/**
 *  Permissions Table:
 *
 *  /=============+=======+=============+=============+=============+=======\
 *  |             | Foun- |    Owner    |    Admin    |    Member   | Other |
 *  |             | der   | Wai Nor Fre | Wai Nor Fre | Wai Nor Fre |       |
 *  +=============+=======+=============+=============+=============+=======+
 *  | 1. found    |  YES  |  -   -   -  |  -   -   -  |  -   -   -  |  -    |
 *  | 2. abdicate |   -   |  NO YES  NO |  -   -   -  |  -   -   -  |  -    |
 *  +-------------+-------+-------------+-------------+-------------+-------+
 *  | 3. invite   |   -   | YES YES YES | YES YES YES |  NO YES  NO |  -    |
 *  | 4. expel    |   -   |  NO YES YES |  NO YES  NO |  NO  NO  NO |  -    |
 *  | 5. join     |   -   |  -   -   -  |  -   -   -  |  -   -   -  | YES   |
 *  | 6. quit     |   -   |  NO  NO  NO |  NO  NO  NO | YES YES  -  |  -    |
 *  +-------------+-------+-------------+-------------+-------------+-------+
 *  | 7. hire     |   -   |  NO YES YES |  NO  NO  NO |  NO  NO  NO |  -    |
 *  | 8. fire     |   -   |  NO YES YES |  NO  NO  NO |  NO  NO  NO |  -    |
 *  | 9. resign   |   -   |  -   -   -  | YES YES  -  |  -   -   -  |  -    |
 *  +-------------+-------+-------------+-------------+-------------+-------+
 *  | 10. speak   |   -   | YES YES YES | YES YES YES | YES YES  NO |  NO   |
 *  | 11. history |  1st  |  NO YES YES |  NO  NO  NO |  NO  NO  NO |  NO   |
 *  \=============+=======+=============+=============+=============+=======/
 *                                (Wai: Waiting, Nor: Normal, Fre: Freezing)
 *
 *  Role Transition Model:
 *
 *        Founder
 *           |      (Freezing) ----+         (Freezing) ------+
 *           |        /            |           /              |
 *           V       /             V          /               V
 *        Owner (Normal)          Member (Normal)           Other User
 *                   \             |  ^   |   \               |
 *                    \            |  |   |    \              |
 *                  (Waiting) <----+  |   |  (Waiting) <------+
 *                     ^              |   |
 *                     |      (Freezing)  |
 *                     |        /         |
 *                   Admin (Normal)       |
 *                              \         |
 *                            (Waiting) <-+
 *
 *      Waiting Owner  == Normal Member (abdicate)
 *      Freezing Owner ~= Normal Member (write history)
 *      Waiting Admin  == Normal Member (hire)
 *      Freezing Admin == Normal Member (fire/resign)
 *      Waiting Member == Normal Member (invite/join)
 *      Freezing Member ~= Others       (expel/quit)
 *
 *  Other rules:
 *      no one can expel itself;
 *      owner/admin cannot be expelled;
 *      only the owner can hire/fire admin;
 *      owner must abdicate before quit;
 *      admin must be fired/resigned before quit.
 */

@end

NS_ASSUME_NONNULL_END
