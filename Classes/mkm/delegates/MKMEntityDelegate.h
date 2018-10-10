//
//  MKMEntityDelegate.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/6.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKMID;
@class MKMMeta;
@class MKMHistoryRecord;
@class MKMHistory;

@protocol MKMEntityDelegate <NSObject>

// meta
- (MKMMeta *)queryMetaWithID:(const MKMID *)ID;

- (void)postMeta:(const MKMMeta *)meta
           forID:(const MKMID *)ID;

// history
- (MKMHistory *)queryHistoryWithID:(const MKMID *)ID;

- (void)postHistory:(const MKMHistory *)history
              forID:(const MKMID *)ID;

- (void)postHistoryRecord:(const MKMHistoryRecord *)record
                    forID:(const MKMID *)ID;

// meta & history
- (void)postMeta:(const MKMMeta *)meta
         history:(const MKMHistory *)history
           forID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
