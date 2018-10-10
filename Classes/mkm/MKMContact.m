//
//  MKMContact.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMProfile.h"
#import "MKMMemo.h"

#import "MKMHistory.h"

#import "MKMEntity+History.h"
#import "MKMPersonHistoryDelegate.h"
#import "MKMEntityManager.h"

#import "MKMContact.h"

@implementation MKMContact

+ (instancetype)contactWithID:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Main, @"addr error");
    MKMEntityManager *em = [MKMEntityManager sharedManager];
    const MKMMeta *meta = [em metaWithID:ID];
    const MKMHistory *history = [em historyWithID:ID];
    MKMContact *contact = [[self alloc] initWithID:ID meta:meta];
    if (contact) {
        MKMPersonHistoryDelegate *delegate;
        delegate = [[MKMPersonHistoryDelegate alloc] init];
        contact.historyDelegate = delegate;
        NSUInteger count = [contact runHistory:history];
        NSAssert(count == history.count, @"history error");
    }
    return contact;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta {
    if (self = [super initWithID:ID meta:meta]) {
        _memo = [[MKMContactMemo alloc] init];
    }
    
    return self;
}

@end
