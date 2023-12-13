// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  DIMCommonArchivist.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/12.
//

#import "DIMCommonArchivist.h"

@interface DIMCommonArchivist ()

@property (strong, nonatomic) id<DIMAccountDBI> database;

@end

@implementation DIMCommonArchivist

- (instancetype)initWithDatabase:(id<DIMAccountDBI>)db {
    if (self = [self initWithDuration:DIMArchivist_QueryExpires]) {
        self.database = db;
    }
    return self;
}

- (NSArray<id<MKMID>> *)localUsers {
    return [_database localUsers];
}

- (NSDate *)lastTimeOfHistoryForID:(id<MKMID>)group {
    NSArray<DIMHistoryCmdMsg *> *array = [_database historiesForGroup:group];
    if ([array count] == 0) {
        return nil;
    }
    NSDate *lastTime;
    NSDate *hisTime;
    for (DIMHistoryCmdMsg *pair in array) {
        hisTime = [pair.first time];
        if (!hisTime) {
            NSAssert(false, @"group command error: %@", pair.first);
        } else if (/* !lastTime || */[lastTime timeIntervalSince1970] < [hisTime timeIntervalSince1970]) {
            lastTime = hisTime;
        }
    }
    return lastTime;
}

- (BOOL)saveMeta:(id<MKMMeta>)meta forID:(id<MKMID>)ID {
    return [_database saveMeta:meta forID:ID];
}

- (BOOL)saveDocument:(id<MKMDocument>)doc {
    NSDate *docTime = [doc time];
    if (!docTime) {
        //NSAssert(false, @"document error: %@", doc);
    } else {
        // calibrate the clock
        // make sure the document time is not in the far future
        NSTimeInterval current = [[[NSDate alloc] init] timeIntervalSince1970];
        current += 64.0;
        if ([docTime timeIntervalSince1970] > current) {
            NSAssert(false, @"document time error: %@, %@", docTime, doc);
            return NO;
        }
    }
    return [_database saveDocument:doc];
}

//
//  EntityDataSource
//

- (id<MKMMeta>)metaForID:(id<MKMID>)ID {
    return [_database metaForID:ID];
}

- (NSArray<id<MKMDocument>> *)documentsForID:(id<MKMID>)ID {
    return [_database documentsForID:ID];
}

//
//  UserDataSource
//

- (NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user {
    return [_database contactsOfUser:user];
}

- (id<MKMEncryptKey>)publicKeyForEncryption:(id<MKMID>)user {
    NSAssert(false, @"don't call me!");
    return nil;
}

- (NSArray<id<MKMVerifyKey>> *)publicKeysForVerification:(id<MKMID>)user {
    NSAssert(false, @"don't call me!");
    return nil;
}

- (NSArray<id<MKMDecryptKey>> *)privateKeysForDecryption:(id<MKMID>)user {
    return [_database privateKeysForDecryption:user];
}

- (id<MKMSignKey>)privateKeyForSignature:(id<MKMID>)user {
    return [_database privateKeyForSignature:user];
}

- (id<MKMSignKey>)privateKeyForVisaSignature:(id<MKMID>)user {
    return [_database privateKeyForVisaSignature:user];
}

//
//  GroupDataSource
//

- (id<MKMID>)founderOfGroup:(id<MKMID>)group {
    return [_database founderOfGroup:group];
}

- (id<MKMID>)ownerOfGroup:(id<MKMID>)group {
    return [_database ownerOfGroup:group];
}

- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    return [_database membersOfGroup:group];
}

- (NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group {
    return [_database assistantsOfGroup:group];
}

//
//  Organization Structure
//

- (NSArray<id<MKMID>> *)administratorsOfGroup:(id<MKMID>)group {
    return [_database administratorsOfGroup:group];
}

- (BOOL)saveAdministrators:(NSArray<id<MKMID>> *)admins group:(id<MKMID>)gid {
    return [_database saveAdministrators:admins group:gid];
}

- (BOOL)saveMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)gid {
    return [_database saveMembers:members group:gid];
}

@end
