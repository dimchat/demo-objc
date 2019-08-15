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
    DIMID *founder = self.founder;
    if (founder) {
        return [founder isEqual:ID];
    } else {
        DIMMeta *meta = self.meta;
        DIMPublicKey *PK = [DIMMetaForID(ID) key];
        NSAssert(PK, @"failed to get meta for ID: %@", ID);
        return [meta matchPublicKey:PK];
    }
}

- (BOOL)existsMember:(DIMID *)ID {
    if ([self.owner isEqual:ID]) {
        return YES;
    }
    NSAssert(_dataSource, @"group data source not set yet");
    NSArray<DIMID *> *members = [self members];
    NSInteger count = [members count];
    if (count <= 0) {
        return NO;
    }
    DIMID *member;
    while (--count >= 0) {
        member = [members objectAtIndex:count];
        if ([member isEqual:ID]) {
            return YES;
        }
    }
    return NO;
}

@end
