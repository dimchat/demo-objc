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
//  DIMGroupAdminManager.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/13.
//

#import "DIMCommonFacebook.h"
#import "DIMCommonMessenger.h"

#import "DIMGroupDelegate.h"

#import "DIMGroupAdminManager.h"

@interface DIMGroupAdminManager ()

@property (strong, nonatomic) DIMGroupDelegate *delegate;

@end

@implementation DIMGroupAdminManager

- (instancetype)initWithDelegate:(DIMGroupDelegate *)delegate {
    if (self = [self init]) {
        self.delegate = delegate;
    }
    return self;
}

- (DIMCommonFacebook *)facebook {
    return [self.delegate facebook];
}

- (DIMCommonMessenger *)messenger {
    return [self.delegate messenger];
}

- (BOOL)updateAdministrators:(NSArray<id<MKMID>> *)newAdmins group:(id<MKMID>)gid {
    NSAssert([gid isGroup], @"group ID error: %@", gid);
    DIMCommonFacebook *facebook = [self facebook];
    NSAssert(facebook, @"facebook not ready");
    
    //
    //  0. get current user
    //
    id<MKMUser> user = [facebook currentUser];
    if (!user) {
        NSAssert(false, @"failed to get current user");
        return nil;
    }
    id<MKMID> me = [user ID];
    id<MKMSignKey> sKey = [facebook privateKeyForVisaSignature:me];
    NSAssert(sKey, @"failed to get sign key for current user: %@", me);
    
    //
    //  1. check permission
    //
    BOOL isOwner = [self.delegate isOwner:me group:gid];
    if (!isOwner) {
        //NSAssert(false, @"cannot update administrators for group: %@, %@", gid, me);
        return NO;
    }
    
    //
    //  2. update document
    //
    id<MKMBulletin> doc = [self.delegate bulletinForID:gid];
    if (!doc) {
        // TODO: create new one?
        NSAssert(false, @"failed to get group document: %@, owner: %@", gid, me);
        return NO;
    }
    [doc setProperty:MKMIDRevert(newAdmins) forKey:@"administrators"];
    NSData *signature = !sKey ? nil : [doc sign:sKey];
    if (!signature) {
        NSAssert(false, @"failed to sign document for group: %@, owner: %@", gid, me);
        return NO;
    } else if (![self.delegate saveDocument:doc]) {
        NSAssert(false, @"failed to save document for group: %@", gid);
        return NO;
    } else {
        NSLog(@"gorup document updated: %@", gid);
    }
    
    //
    //  3. broadcast bulletin document
    //
    return [self broadcastDocument:doc];
}

- (BOOL)broadcastDocument:(id<MKMBulletin>)doc {
    DIMCommonFacebook *facebook = [self facebook];
    DIMCommonMessenger *messenger = [self messenger];
    NSAssert(facebook, @"facebook messenger not ready: %@, %@", facebook, messenger);
    
    //
    //  0. get current user
    //
    id<MKMUser> user = [facebook currentUser];
    if (!user) {
        NSAssert(false, @"failed to get current user");
        return nil;
    }
    id<MKMID> me = [user ID];
    
    //
    //  1. create 'document' command, and send to current station
    //
    id<MKMID> group = [doc ID];
    id<MKMMeta> meta = [facebook metaForID:group];
    id<DKDCommand> content = DIMDocumentCommandResponse(group, meta, doc);
    [messenger sendContent:content sender:me receiver:MKMAnyStation() priority:1];
    
    //
    //  2. check group bots
    //
    NSArray<id<MKMID>> *bots = [self.delegate assistantsOfGroup:group];
    if ([bots count] > 0) {
        // group bots exist, let them to deliver to all other members
        for (id<MKMID> item in bots) {
            if ([me isEqual:item]) {
                NSAssert(false, @"should not be a bot here");
                continue;
            }
            [messenger sendContent:content sender:me receiver:item priority:1];
        }
        return YES;
    }

    //
    //  3. broadcast to all members
    //
    NSArray<id<MKMID>> *members = [self.delegate membersOfGroup:group];
    if ([members count] == 0) {
        NSAssert(false, @"failed to get group members: %@", group);
        return NO;
    }
    for (id<MKMID> item in members) {
        if ([me isEqual:item]) {
            NSLog(@"skip cycled message: %@, %@", item, group);
            continue;
        }
        [messenger sendContent:content sender:me receiver:item priority:1];
    }
    return YES;
}

@end
