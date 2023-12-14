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
//  DIMGroupDelegate.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/13.
//

#import "DIMClientFacebook.h"

#import "DIMGroupDelegate.h"

@implementation DIMGroupDelegate

- (nullable id<MKMBulletin>)bulletinForID:(id<MKMID>)gid {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook bulletinForID:gid];
}

- (BOOL)saveDocument:(id<MKMDocument>)doc {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook saveDocument:doc];
}

//
//  Entity DataSource
//

- (nullable id<MKMMeta>)metaForID:(id<MKMID>)ID {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook metaForID:ID];
}

- (NSArray<id<MKMDocument>> *)documentsForID:(id<MKMID>)ID {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook documentsForID:ID];
}

//
//  Group DataSource
//

- (nullable id<MKMID>)founderOfGroup:(id<MKMID>)group {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook founderOfGroup:group];
}

- (nullable id<MKMID>)ownerOfGroup:(id<MKMID>)group {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook ownerOfGroup:group];
}

- (NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook assistantsOfGroup:group];
}

- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook membersOfGroup:group];
}

@end

@implementation DIMGroupDelegate (Members)

- (NSString *)buildGroupNameWithMembers:(NSArray<id<MKMID>> *)members {
    NSUInteger count = [members count];
    NSAssert(count > 0, @"members should not be empty here");
    DIMCommonFacebook *facebook = [self facebook];
    NSString *text = [facebook nameForID:members.firstObject];
    NSString *nickname;
    for (NSUInteger i = 1; i < count; ++i) {
        nickname = [facebook nameForID:[members objectAtIndex:i]];
        if ([nickname length] == 0) {
            continue;
        }
        text = [text stringByAppendingFormat:@", %@", nickname];
        if ([text length] > 32) {
            text = [text substringToIndex:28];
            return [text stringByAppendingString:@" ..."];
        }
    }
    return text;
}

- (BOOL)saveMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)gid {
    DIMClientFacebook *facebook = [self facebook];
    return [facebook saveMembers:members group:gid];
}

@end

@implementation DIMGroupDelegate (Administrators)

- (NSArray<id<MKMID>> *)administratorsOfGroup:(id<MKMID>)gid {
    DIMClientFacebook *facebook = [self facebook];
    return [facebook administratorsOfGroup:gid];
}

- (BOOL)saveAdministrators:(NSArray<id<MKMID>> *)admins group:(id<MKMID>)gid {
    DIMClientFacebook *facebook = [self facebook];
    return [facebook saveAdministrators:admins group:gid];
}

@end

@implementation DIMGroupDelegate (Membership)

- (BOOL)isFounder:(id<MKMID>)uid group:(id<MKMID>)gid {
    NSAssert([uid isUser] && [gid isGroup], @"ID error: %@, %@", uid, gid);
    id<MKMID> founder = [self founderOfGroup:gid];
    if (founder) {
        return [founder isEqual:uid];
    }
    // check member's public key with group's meta.key
    id<MKMMeta> gMeta = [self metaForID:gid];
    id<MKMMeta> uMeta = [self metaForID:uid];
    if (gMeta && uMeta) {
        return [gMeta matchPublicKey:uMeta.publicKey];
    }
    NSAssert(false, @"failed to get meta for group: %@, user: %@", gid, uid);
    return NO;
}

- (BOOL)isOwner:(id<MKMID>)uid group:(id<MKMID>)gid {
    NSAssert([uid isUser] && [gid isGroup], @"ID error: %@, %@", uid, gid);
    id<MKMID> owner = [self ownerOfGroup:gid];
    if (owner) {
        return [owner isEqual:uid];
    }
    if ([gid type] == MKMEntityType_Group) {
        // this is a polylogue
        return [self isFounder:uid group:gid];
    }
    NSAssert(false, @"only polylogue so far");
    return NO;
}

- (BOOL)isMember:(id<MKMID>)uid group:(id<MKMID>)gid {
    NSAssert([uid isUser] && [gid isGroup], @"ID error: %@, %@", uid, gid);
    NSArray<id<MKMID>> *members = [self membersOfGroup:gid];
    return [members containsObject:uid];
}

- (BOOL)isAdministrator:(id<MKMID>)uid group:(id<MKMID>)gid {
    NSAssert([uid isUser] && [gid isGroup], @"ID error: %@, %@", uid, gid);
    NSArray<id<MKMID>> *admins = [self administratorsOfGroup:gid];
    return [admins containsObject:uid];
}

- (BOOL)isAssistant:(id<MKMID>)bid group:(id<MKMID>)gid {
    NSAssert([bid isUser] && [gid isGroup], @"ID error: %@, %@", bid, gid);
    NSArray<id<MKMID>> *bots = [self assistantsOfGroup:gid];
    return [bots containsObject:bid];
}

@end
