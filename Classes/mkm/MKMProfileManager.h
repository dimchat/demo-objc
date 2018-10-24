//
//  MKMProfileManager.h
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

- (nullable MKMProfile *)queryProfileForID:(const MKMID *)ID;

- (void)postProfile:(const MKMProfile *)profile
              forID:(const MKMID *)ID;

@end

/**
 *  Profile Manager
 *
 *      To look up someone's profile on the Internet social network 'MKM'
 */
@interface MKMProfileManager : NSObject

@property (weak, nonatomic) id<MKMProfileDelegate> delegate;;

+ (instancetype)sharedInstance;

- (MKMProfile *)profileWithID:(const MKMID *)ID;
- (void)setProfile:(MKMProfile *)profile forID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
