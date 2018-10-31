//
//  MKMEntity.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKMID;
@class MKMMeta;

@interface MKMEntity : NSObject {
    
    MKMID *_ID;
    MKMMeta *_meta;
}

@property (readonly, strong, nonatomic) MKMID *ID;   // name@address

@property (readonly, nonatomic) MKMNetworkType type; // Network ID
@property (readonly, nonatomic) UInt32 number;       // search number
@property (strong, nonatomic) NSString *name;        // name or seed

- (instancetype)initWithID:(const MKMID *)ID
                      meta:(const MKMMeta *)meta
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
