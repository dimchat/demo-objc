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
    
    MKMAccountHistoryDelegate *_defaultAccountDelegate;
    MKMGroupHistoryDelegate *_defaultGroupDelegate;
}

@end

@implementation MKMConsensus

static MKMConsensus *s_sharedInstance = nil;

+ (instancetype)sharedInstance {
    if (!s_sharedInstance) {
        s_sharedInstance = [[self alloc] init];
    }
    return s_sharedInstance;
}

+ (instancetype)alloc {
    NSAssert(!s_sharedInstance, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        _defaultAccountDelegate = [[MKMAccountHistoryDelegate alloc] init];
        _defaultGroupDelegate = [[MKMGroupHistoryDelegate alloc] init];
        
        _accountHistoryDelegate = nil;
        _groupHistoryDelegate = nil;
    }
    return self;
}

#pragma mark - MKMEntityHistoryDelegate

- (id<MKMEntityHistoryDelegate>)historyDelegateWithID:(const MKMID *)ID {
    MKMEntityHistoryDelegate *delegate = nil;
    switch (ID.address.network) {
        case MKMNetwork_Main:
            if (_accountHistoryDelegate) {
                delegate = _accountHistoryDelegate;
            } else {
                delegate = _defaultAccountDelegate;
            }
            break;
            
        case MKMNetwork_Group:
            if (_groupHistoryDelegate) {
                delegate = _groupHistoryDelegate;
            } else {
                delegate = _defaultGroupDelegate;
            }
            break;
            
        default:
            NSAssert(false, @"network type not support");
            break;
    }
    return delegate;
}

- (BOOL)recorder:(const MKMID *)ID
  canWriteRecord:(const MKMHistoryRecord *)record
        inEntity:(const MKMEntity *)entity {
    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
    id<MKMEntityHistoryDelegate> delegate;
    delegate = [self historyDelegateWithID:ID];
    return [delegate recorder:ID canWriteRecord:record inEntity:entity];
}

- (BOOL)commander:(const MKMID *)ID
       canExecute:(const MKMHistoryOperation *)operation
         inEntity:(const MKMEntity *)entity {
    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
    id<MKMEntityHistoryDelegate> delegate;
    delegate = [self historyDelegateWithID:ID];
    return [delegate commander:ID canExecute:operation inEntity:entity];
}

- (void)commander:(const MKMID *)ID
          execute:(const MKMHistoryOperation *)operation
         inEntity:(const MKMEntity *)entity {
    NSAssert(ID.address.network == MKMNetwork_Main, @"ID error");
    id<MKMEntityHistoryDelegate> delegate;
    delegate = [self historyDelegateWithID:ID];
    return [delegate commander:ID execute:operation inEntity:entity];
}

@end
