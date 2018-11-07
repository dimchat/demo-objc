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

- (BOOL)historyRecorder:(const MKMID *)recorder
          canWriteBlock:(const MKMHistoryBlock *)record
               inEntity:(const MKMEntity *)entity {
    if (![recorder isValid]) {
        return NO;
    }
    // let the subclass to define the permissions
    return YES;
}

- (BOOL)historyCommander:(const MKMID *)commander
              canExecute:(const MKMHistoryOperation *)operation
                inEntity:(const MKMEntity *)entity {
    if (![commander isValid]) {
        return NO;
    }
    // let the subclass to define the permissions
    return YES;
}

- (void)historyCommander:(const MKMID *)commander
                 execute:(const MKMHistoryOperation *)operation
                inEntity:(const MKMEntity *)entity {
    // let the subclass to do the operating
    return ;
}

@end
