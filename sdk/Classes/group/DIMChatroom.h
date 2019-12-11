// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMChatroom.h
//  DIMCore
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

/*
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
 *  Bits:
 *      0000 0001 - speak
 *      0000 0010 - rename
 *      0000 0100 - invite
 *      0000 1000 - expel (admin)
 *
 *      0001 0000 - abdicate/hire/fire (owner)
 *      0010 0000 - write history
 *      0100 0000 - Waiting
 *      1000 0000 - Freezing
 *
 *      (All above are just some advices to help choosing numbers :P)
 */
typedef NS_ENUM(UInt8, DIMMemberType) {
    DIMMember_Founder = 0x20, // 0010 0000
    DIMMember_Owner   = 0x3F, // 0011 1111
    DIMMember_Admin   = 0x0F, // 0000 1111
    DIMMember_Member  = 0x07, // 0000 0111
    DIMMember_Other   = 0x00, // 0000 0000
    
    DIMMember_Freezing = 0x80, // 1000 0000
    DIMMember_Waiting  = 0x40, // 0100 0000
    
    DIMMember_OwnerWaiting   = DIMMember_Owner  | DIMMember_Waiting,
    DIMMember_OwnerFreezing  = DIMMember_Owner  | DIMMember_Freezing,
    DIMMember_AdminWaiting   = DIMMember_Admin  | DIMMember_Waiting,
    DIMMember_AdminFreezing  = DIMMember_Admin  | DIMMember_Freezing,
    DIMMember_MemberWaiting  = DIMMember_Member | DIMMember_Waiting,
    DIMMember_MemberFreezing = DIMMember_Member | DIMMember_Freezing,
};
typedef UInt8 DIMMemberRole;

@interface DIMChatroom : DIMGroup

@property (readonly, copy, nonatomic) NSArray<DIMID *> *admins;

- (BOOL)existsAdmin:(DIMID *)ID;

// -hire(admin, owner)
// -fire(admin, owner)
// -resign(admin)

@end

#pragma mark - Chatroom Delegate

@protocol DIMChatroomDataSource <DIMGroupDataSource>

/**
 *  Get chatroom admin list
 *
 * @param chatroom - group ID
 * @return admins list (ID)
 */
- (nullable NSArray<DIMID *> *)adminsOfChatroom:(DIMID *)chatroom;

@end

NS_ASSUME_NONNULL_END
