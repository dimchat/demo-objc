//
//  MKMConsensus.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/11.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMAddress.h"

#import "MKMAccountHistoryDelegate.h"
#import "MKMGroupHistoryDelegate.h"

#import "MKMConsensus.h"

@interface MKMConsensus () {
    
    MKMAccountHistoryDelegate *_accountDelegate;
    MKMGroupHistoryDelegate *_groupDelegate;
}

@end

@implementation MKMConsensus

static MKMConsensus *s_sharedInstance = nil;

+ (instancetype)sharedInstance {
    if (!s_sharedInstance) {
        s_sharedInstance = [[self alloc] init];
    return s_sharedInstance;
}

+ (instancetype)alloc {
    NSAssert(!s_sharedInstance, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        _accountDelegate = [[MKMAccountHistoryDelegate alloc] init];
        _groupDelegate = [[MKMGroupHistoryDelegate alloc] init];
    }
    return self;
}

#pragma mark - MKMEntityHistoryDelegate

- (MKMEntityHistoryDelegate *)historyDelegateWithID:(const MKMID *)ID {
    MKMEntityHistoryDelegate *delegate = nil;
    switch (ID.address.network) {
        case MKMNetwork_Main:
            delegate = _accountDelegate;
            break;
            
        case MKMNetwork_Group:
            delegate = _groupDelegate;
            break;
            
        default:
            NSAssert(false, @"network type not support");
            break;
    }
    return delegate;
}

- (BOOL)recorder:(nonnull const MKMID *)ID canWriteRecord:(nonnull const MKMHistoryRecord *)record inEntity:(nonnull const MKMEntity *)entity {
    MKMEntityHistoryDelegate *delegate = [self historyDelegateWithID:ID];
    return [delegate recorder:ID canWriteRecord:record inEntity:entity];
}

- (BOOL)commander:(nonnull const MKMID *)ID
       canExecute:(nonnull const MKMHistoryOperation *)operation
         inEntity:(nonnull const MKMEntity *)entity {
    MKMEntityHistoryDelegate *delegate = [self historyDelegateWithID:ID];
    return [delegate commander:ID canExecute:operation inEntity:entity];
}

- (void)commander:(nonnull const MKMID *)ID
          execute:(nonnull const MKMHistoryOperation *)operation
         inEntity:(nonnull const MKMEntity *)entity {
    MKMEntityHistoryDelegate *delegate = [self historyDelegateWithID:ID];
    return [delegate commander:ID execute:operation inEntity:entity];
}

@end
