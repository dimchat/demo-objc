//
//  MKMGroup+Extension.m
//  DIMCore
//
//  Created by Albert Moky on 2019/3/18.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMFacebook.h"

#import "MKMGroup+Extension.h"

@implementation MKMGroup (Extension)

- (BOOL)isFounder:(DIMID *)ID {
    DIMID *founder = [self founder];
    if (founder) {
        return [founder isEqual:ID];
    } else {
        DIMMeta *meta = [self meta];
        DIMPublicKey *PK = [DIMMetaForID(ID) key];
        NSAssert(PK, @"failed to get meta for ID: %@", ID);
        return [meta matchPublicKey:PK];
    }
}

- (BOOL)existsMember:(DIMID *)ID {
    // check broadcast ID
    if ([_ID isBroadcast]) {
        // anyone user is a member of the broadcast group 'everyone@everywhere'
        return MKMNetwork_IsUser([ID type]);
    }
    // check all member(s)
    NSArray<DIMID *> *members = [self members];
    for (DIMID *item in members) {
        if ([item isEqual:ID]) {
            return YES;
        }
    }
    // check owner
    DIMID *owner = [self owner];
    return [owner isEqual:ID];
}

@end
