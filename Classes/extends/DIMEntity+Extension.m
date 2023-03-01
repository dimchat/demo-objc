// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
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
//  DIMEntity+Extension.m
//  DIMP
//
//  Created by Albert Moky on 2019/8/12.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "MKMAnonymous.h"
#import "DIMFacebook+Extension.h"

#import "DIMEntity+Extension.h"

@implementation DIMEntity (Name)

- (NSString *)name {
    DIMFacebook *facebook = (DIMFacebook *)[self dataSource];
    return [facebook name:self.ID];
}

@end

@implementation DIMStation (Name)

- (NSString *)name {
    DIMFacebook *facebook = (DIMFacebook *)[self dataSource];
    NSString *str = [facebook name:self.ID];
    return [@"[MTA] " stringByAppendingString:str];
}

@end

@implementation DIMUser (LocalUser)

+ (nullable instancetype)userWithConfigFile:(NSString *)config {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:config];
    
    if (!dict) {
        NSLog(@"failed to load: %@", config);
        return nil;
    }
    
    id<MKMID> ID = MKMIDParse([dict objectForKey:@"ID"]);
    id<MKMMeta> meta = MKMMetaParse([dict objectForKey:@"meta"]);
    
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    [facebook saveMeta:meta forID:ID];
    
    // save private key paired to meta.key
    id<MKMPrivateKey> SK = MKMPrivateKeyParse([dict objectForKey:@"privateKey"]);
    [facebook savePrivateKey:SK type:DIMPrivateKeyType_Meta user:ID];
    
    DIMUser *user = (DIMUser *)DIMUserWithID(ID);
    
    // profile
    id profile = [dict objectForKey:@"profile"];
    if (profile) {
        // copy profile from config to local storage
        if (![profile objectForKey:@"ID"]) {
            NSMutableDictionary *mDict;
            if ([profile isKindOfClass:[NSMutableDictionary class]]) {
                mDict = (NSMutableDictionary *) profile;
            } else {
                mDict = [profile mutableCopy];
                profile = mDict;
            }
            [mDict setObject:ID forKey:@"ID"];
        }
        profile = MKMDocumentParse(profile);
        [[DIMFacebook sharedInstance] saveDocument:profile];
    }
    
    return user;
}

- (void)addContact:(id<MKMID>)contact {
    [[DIMFacebook sharedInstance] user:self.ID addContact:contact];
}

- (void)removeContact:(id<MKMID>)contact {
    [[DIMFacebook sharedInstance] user:self.ID removeContact:contact];
}

@end

@implementation DIMGroup (Extension)

- (NSArray<id<MKMID>> *)assistants {
    DIMFacebook *facebook = [DIMFacebook sharedInstance];
    NSArray *list = [facebook assistantsOfGroup:self.ID];
    return [list mutableCopy];
}

- (BOOL)isFounder:(id<MKMID>)ID {
    id<MKMID> founder = [self founder];
    if (founder) {
        return [founder isEqual:ID];
    } else {
        id<MKMMeta> meta = [self meta];
        id<MKMMeta> uMeta = DIMMetaForID(ID);
        id<MKMVerifyKey> PK = [uMeta key];
        //NSAssert(PK, @"failed to get meta for ID: %@", ID);
        return MKMMetaMatchKey(PK, meta);
    }
}

- (BOOL)isOwner:(id<MKMID>)ID {
    if (self.ID.type == MKMNetwork_Polylogue) {
        return [self isFounder:ID];
    }
    // check owner
    id<MKMID> owner = [self owner];
    return [owner isEqual:ID];
}

- (BOOL)existsAssistant:(id<MKMID>)ID {
    NSArray<id<MKMID>> *assistants = [self assistants];
    return [assistants containsObject:ID];
}

- (BOOL)existsMember:(id<MKMID>)ID {
    // check broadcast ID
    if (MKMIDIsBroadcast(self.ID)) {
        // anyone user is a member of the broadcast group 'everyone@everywhere'
        return MKMIDIsUser(ID);
    }
    // check all member(s)
    NSArray<id<MKMID>> *members = [self members];
    for (id<MKMID> item in members) {
        if ([item isEqual:ID]) {
            return YES;
        }
    }
    // check owner
    return [self isOwner:ID];
}

@end
