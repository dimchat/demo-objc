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
//  DIMClient
//
//  Created by Albert Moky on 2023/3/4.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "MKMAnonymous.h"
#import "DIMCommonArchivist.h"

#import "DIMCommonFacebook.h"

@interface DIMCommonFacebook () {
    
    id<MKMUser> _currentUser;
}

@end

@implementation DIMCommonFacebook

- (id<MKMUser>)currentUser {
    // Get current user (for signing and sending message)
    id<MKMUser> user = _currentUser;
    if (user == nil) {
        NSArray<id<MKMUser>> *localUsers = [self localUsers];
        if ([localUsers count] > 0) {
            user = [localUsers firstObject];
            _currentUser = user;
        }
    }
    return user;
}

- (void)setCurrentUser:(id<MKMUser>)currentUser {
    if (!currentUser.dataSource) {
        currentUser.dataSource = self;
    }
    _currentUser = currentUser;
}

// Override
- (NSArray<id<MKMUser>> *)localUsers {
    NSMutableArray<id<MKMUser>> *allUsers;
    id<MKMUser> user;

    NSArray<id<MKMID>> *array = [self.archivist localUsers];
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
            allUsers = [[NSMutableArray alloc] init];
        } else {
            allUsers = [[NSMutableArray alloc] initWithCapacity:1];
            [allUsers addObject:user];
        }
    }
    return allUsers;
}

- (nullable id<MKMDocument>)documentForID:(id<MKMID>)ID
                                 withType:(nullable NSString *)type {
    NSArray<id<MKMDocument>> *docs = [self documentsForID:ID];
    id<MKMDocument> doc = [DIMDocumentHelper lastDocument:docs
                                                  forType:type];
    // compatible for document type
    if (!doc && [type isEqualToString:MKMDocumentType_Visa]) {
        doc = [DIMDocumentHelper lastDocument:docs
                                      forType:MKMDocumentType_Profile];
    }
    return doc;
}

- (NSString *)nameForID:(id<MKMID>)ID {
    NSString *type;
    if ([ID isUser]) {
        type = MKMDocumentType_Visa;
    } else if ([ID isGroup]) {
        type = MKMDocumentType_Bulletin;
    } else {
        type = @"*";
    }
    // get name from document
    id<MKMDocument> doc = [self documentForID:ID withType:type];
    if (doc) {
        NSString *name = [doc name];
        if ([name length] > 0) {
            return name;
        }
    }
    // get name from ID
    return [MKMAnonymous name:ID];
}

//
//  UserDataSource
//

- (NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user {
    DIMCommonArchivist *archivist = [self archivist];
    return [archivist contactsOfUser:user];
}

- (NSArray<id<MKMDecryptKey>> *)privateKeysForDecryption:(id<MKMID>)user {
    DIMCommonArchivist *archivist = [self archivist];
    return [archivist privateKeysForDecryption:user];
}

- (id<MKMSignKey>)privateKeyForSignature:(id<MKMID>)user {
    DIMCommonArchivist *archivist = [self archivist];
    return [archivist privateKeyForSignature:user];
}

- (id<MKMSignKey>)privateKeyForVisaSignature:(id<MKMID>)user {
    DIMCommonArchivist *archivist = [self archivist];
    return [archivist privateKeyForVisaSignature:user];
}

@end
