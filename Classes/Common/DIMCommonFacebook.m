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
//  DIMCommonFacebook.m
//  DIMP
//
//  Created by Albert Moky on 2023/3/4.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "MKMAnonymous.h"
#import "DIMRegister.h"

#import "DIMCommonFacebook.h"

@interface DIMCommonFacebook () {
    
    id<MKMUser> _currentUser;
}

@property(nonatomic, strong) id<DIMAccountDBI> database;

@end

@implementation DIMCommonFacebook

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    id<DIMAccountDBI> db = nil;
    return [self initWithDatabase:db];
}

/* designated initializer */
- (instancetype)initWithDatabase:(id<DIMAccountDBI>)db {
    if (self = [super init]) {
        _database = db;
        _currentUser = nil;
    }
    return self;
}

- (id<MKMUser>)currentUser {
    // Get current user (for signing and sending message)
    id<MKMUser> user = _currentUser;
    if (user == nil) {
        NSArray<id<MKMUser>> *localUsers = [self localUsers];
        if ([localUsers count] > 0) {
            user = [localUsers objectAtIndex:0];
            _currentUser = user;
        }
    }
    return user;
}

- (void)setCurrentUser:(id<MKMUser>)currentUser {
    _currentUser = currentUser;
}

// Override
- (NSArray<id<MKMUser>> *)localUsers {
    NSMutableArray<id<MKMUser>> *allUsers;
    id<MKMUser> user;

    NSArray<id<MKMID>> *array = [_database localUsers];
    NSUInteger count = [array count];
    if (count > 0) {
        allUsers = [[NSMutableArray alloc] initWithCapacity:count];
        for (id<MKMID> item in array) {
            NSAssert([self privateKeyForSignature:item], @"private key not found: %@", item);
            user = [self userWithID:item];
            NSAssert(user, @"failed to create user: %@", item);
            [allUsers addObject:user];
        }
    } else {
        user = _currentUser;
        if (user == nil) {
            allUsers = nil;
        } else {
            allUsers = [[NSMutableArray alloc] initWithCapacity:1];
            [allUsers addObject:user];
        }
    }
    return allUsers;
}

// Override
- (BOOL)saveMeta:(id<MKMMeta>)meta forID:(id<MKMID>)ID {
    return [_database saveMeta:meta forID:ID];
}

// Override
- (BOOL)saveDocument:(id<MKMDocument>)doc {
    return [_database saveDocument:doc];
}

// Override
- (BOOL)saveMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)ID {
    return [_database saveMembers:members group:ID];
}

- (BOOL)saveAssistants:(NSArray<id<MKMID>> *)bots group:(id<MKMID>)ID {
    return [_database saveAssistants:bots group:ID];
}

// Override
- (id<MKMUser>)createUser:(id<MKMID>)ID {
    if (!MKMIDIsBroadcast(ID)) {
        if ([self publicKeyForEncryption:ID] == nil) {
            // visa.key not found
            return nil;
        }
    }
    return [super createUser:ID];
}

// Override
- (id<MKMGroup>)createGroup:(id<MKMID>)ID {
    if (!MKMIDIsBroadcast(ID)) {
        if ([self metaForID:ID] == nil) {
            // group meta not found
            return nil;
        }
    }
    return [super createGroup:ID];
}

//
//  EntityDelegate
//

// Override
- (id<MKMMeta>)metaForID:(id<MKMID>)ID {
    /*/
    if (MKMIDIsBroadcast(ID)) {
        // broadcast ID has no meta
        return nil;
    }
    /*/
    return [_database metaForID:ID];
}

// Override
- (id<MKMDocument>)documentForID:(id<MKMID>)ID type:(NSString *)type {
    /*/
    if (MKMIDIsBroadcast(ID)) {
        // broadcast ID has no document
        return nil;
    }
    /*/
    return [_database documentForID:ID withType:type];
}

//
//  UserDataSource
//

// Override
- (NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user {
    return [_database contactsForUser:user];
}

// Override
- (NSArray<id<MKMDecryptKey>> *)privateKeysForDecryption:(id<MKMID>)user {
    return [_database privateKeysForDecryption:user];
}

// Override
- (id<MKMSignKey>)privateKeyForSignature:(id<MKMID>)user {
    return [_database privateKeyForSignature:user];
}

// Override
- (id<MKMSignKey>)privateKeyForVisaSignature:(id<MKMID>)user {
    return [_database privateKeyForVisaSignature:user];
}

//
//  GroupDataSource
//

// Override
- (id<MKMID>)founderOfGroup:(id<MKMID>)group {
    id<MKMID> founder = [_database founderOfGroup:group];
    if (founder) {
        // got from database
        return founder;
    }
    return [super founderOfGroup:group];
}

// Override
- (id<MKMID>)ownerOfGroup:(id<MKMID>)group {
    id<MKMID> owner = [_database ownerOfGroup:group];
    if (owner) {
        // got from database
        return owner;
    }
    return [super ownerOfGroup:group];
}

// Override
- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    NSArray<id<MKMID>> *members = [_database membersOfGroup:group];
    if ([members count] > 0) {
        // got from database
        return members;
    }
    return [super membersOfGroup:group];
}

// Override
- (NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group {
    NSArray<id<MKMID>> *bots = [_database assistantsOfGroup:group];
    if ([bots count] > 0) {
        // got from database
        return bots;
    }
    return [super assistantsOfGroup:group];
}

@end

#pragma mark - IDFactory

static DIMAddressNameServer *_ans = nil;
static id<MKMIDFactory> _idFactory = nil;

@interface IDFactory : NSObject <MKMIDFactory>

@end

@implementation IDFactory

- (nonnull id<MKMID>)createID:(nullable NSString *)name
                      address:(id<MKMAddress>)address
                     terminal:(nullable NSString *)location {
    return [_idFactory createID:name address:address terminal:location];
}

- (nonnull id<MKMID>)generateIDWithMeta:(id<MKMMeta>)meta
                                   type:(MKMEntityType)network
                               terminal:(nullable NSString *)location {
    return [_idFactory generateIDWithMeta:meta type:network terminal:location];
}

- (nullable id<MKMID>)parseID:(nonnull NSString *)identifier {
    // try ANS record
    id<MKMID> ID = [_ans getID:identifier];
    if (ID) {
        return ID;
    }
    // parse by original factory
    return [_idFactory parseID:identifier];
}

@end

#pragma mark - Client Facebook

@implementation DIMCommonFacebook (Client)

- (NSString *)nameForID:(id<MKMID>)ID {
    // get name from document
    id<MKMDocument> doc = [self documentForID:ID type:@"*"];
    if (doc) {
        NSString *name = [doc name];
        if ([name length] > 0) {
            return name;
        }
    }
    // get name from ID
    return [MKMAnonymous name:ID];
}

+ (DIMAddressNameServer *)ans {
    return _ans;
}

+ (void)setANS:(DIMAddressNameServer *)ans {
    _ans = ans;
}

+ (void)prepare {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        // load plugins
        [DIMRegister prepare];
        
        _idFactory = MKMIDGetFactory();
        MKMIDSetFactory([[IDFactory alloc] init]);
        
    });
}

@end
