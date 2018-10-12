//
//  MKMProfileDelegate.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/10.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKMID;
@class MKMProfile;

@protocol MKMProfileDelegate <NSObject>

- (nullable MKMProfile *)queryProfileWithID:(const MKMID *)ID;

- (void)postProfile:(const MKMProfile *)profile
              forID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
