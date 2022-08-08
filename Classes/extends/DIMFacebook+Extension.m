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
//  DIMFacebook+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/11/29.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "MKMAnonymous.h"
#import "SCFacebook.h"

#import "DIMFacebook+Extension.h"

@implementation DIMFacebook (Extension)

+ (instancetype)sharedInstance {
    return [SCFacebook sharedInstance];
}

- (void)setCurrentUser:(id<DIMUser>)user {
    NSAssert(false, @"implement me!");
}

- (BOOL)saveUsers:(NSArray<id<MKMID>> *)list {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)savePrivateKey:(id<MKMPrivateKey>)key type:(NSString *)type user:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)saveContacts:(NSArray<id<MKMID>> *)contacts user:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)user:(id<MKMID>)user addContact:(id<MKMID>)contact {
    NSLog(@"user %@ add contact %@", user, contact);
    NSArray<id<MKMID>> *contacts = [self contactsOfUser:user];
    if (contacts) {
        if ([contacts containsObject:contact]) {
            NSLog(@"contact %@ already exists, user: %@", contact, user);
            return NO;
        } else if (![contacts respondsToSelector:@selector(addObject:)]) {
            // mutable
            contacts = [contacts mutableCopy];
        }
    } else {
        contacts = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [(NSMutableArray *)contacts addObject:contact];
    return [self saveContacts:contacts user:user];
}

- (BOOL)user:(id<MKMID>)user removeContact:(id<MKMID>)contact {
    NSLog(@"user %@ remove contact %@", user, contact);
    NSArray<id<MKMID>> *contacts = [self contactsOfUser:user];
    if (contacts) {
        if (![contacts containsObject:contact]) {
            NSLog(@"contact %@ not exists, user: %@", contact, user);
            return NO;
        } else if (![contacts respondsToSelector:@selector(removeObject:)]) {
            // mutable
            contacts = [contacts mutableCopy];
        }
    } else {
        NSLog(@"user %@ doesn't has contact yet", user);
        return NO;
    }
    [(NSMutableArray *)contacts removeObject:contact];
    return [self saveContacts:contacts user:user];
}

- (BOOL)group:(id<MKMID>)group addMember:(id<MKMID>)member {
    NSLog(@"group %@ add member %@", group, member);
    NSArray<id<MKMID>> *members = [self membersOfGroup:group];
    if (members) {
        if ([members containsObject:member]) {
            NSLog(@"member %@ already exists, group: %@", member, group);
            return NO;
        } else if (![members respondsToSelector:@selector(addObject:)]) {
            // mutable
            members = [members mutableCopy];
        }
    } else {
        members = [[NSMutableArray alloc] initWithCapacity:1];
    }
    [(NSMutableArray *)members addObject:member];
    return [self saveMembers:members group:group];
}

- (BOOL)group:(id<MKMID>)group removeMember:(id<MKMID>)member {
    NSLog(@"group %@ remove member %@", group, member);
    NSArray<id<MKMID>> *members = [self membersOfGroup:group];
    if (members) {
        if (![members containsObject:member]) {
            NSLog(@"members %@ not exists, group: %@", member, group);
            return NO;
        } else if (![members respondsToSelector:@selector(removeObject:)]) {
            // mutable
            members = [members mutableCopy];
        }
    } else {
        NSLog(@"group %@ doesn't has member yet", group);
        return NO;
    }
    [(NSMutableArray *)members removeObject:member];
    return [self saveMembers:members group:group];
}

- (nullable NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group {
    NSArray<id<MKMID>> *assistants = [super assistantsOfGroup:group];
    if (assistants.count == 0) {
        id<MKMID> ass = MKMIDFromString(@"assistant");
        if (ass) {
            assistants = @[ass];
        }
    }
    return assistants;
}

- (BOOL)group:(id<MKMID>)group containsMember:(id<MKMID>)member {
    NSArray<id<MKMID>> *members = [self membersOfGroup:group];
    return [members containsObject:member];
}

- (BOOL)group:(id<MKMID>)group containsAssistant:(id<MKMID>)assistant {
    NSArray<id<MKMID>> *assistants = [self assistantsOfGroup:group];
    return [assistants containsObject:assistant];
}

- (NSString *)name:(id<MKMID>)ID {
    // get name from document
    id<MKMDocument> doc = [self documentForID:ID type:@"*"];
    NSString *str = [doc name];
    if (str.length > 0) {
        return str;
    }
    // get name from ID
    return [MKMAnonymous name:ID];
}

@end
