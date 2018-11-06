//
//  MKMEntityHistoryDelegate.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMEntity.h"

#import "MKMHistoryBlock.h"
#import "MKMHistory.h"

#import "MKMEntityHistoryDelegate.h"

@implementation MKMEntityHistoryDelegate

- (BOOL)recorder:(nonnull const MKMID *)ID
   canWriteBlock:(nonnull const MKMHistoryBlock *)record
        inEntity:(nonnull const MKMEntity *)entity {
    if (![ID isValid]) {
        return NO;
    }
    // let the subclass to define the permissions
    return YES;
}

- (BOOL)commander:(nonnull const MKMID *)ID
       canExecute:(nonnull const MKMHistoryOperation *)operation
         inEntity:(nonnull const MKMEntity *)entity {
    if (![ID isValid]) {
        return NO;
    }
    // let the subclass to define the permissions
    return YES;
}

- (void)commander:(nonnull const MKMID *)ID
          execute:(nonnull const MKMHistoryOperation *)operation
         inEntity:(nonnull const MKMEntity *)entity {
    // let the subclass to do the operating
    return ;
}

@end
