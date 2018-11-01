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

@protocol MKMProfileDataSource <NSObject>

// query
- (MKMProfile *)profileForEntityID:(const MKMID *)ID;

@end

@protocol MKMProfileDelegate <NSObject>

// send
- (void)entityID:(const MKMID *)ID sendProfile:(const MKMProfile *)profile;

// receive
- (void)entityID:(const MKMID *)ID didReceiveProfile:(const MKMProfile *)profile;

@end

#pragma mark -

#define MKMProfileForID(ID) [[MKMProfileManager sharedInstance] profileForID:(ID)]

/**
 *  Profile Manager
 *
 *      To look up someone's profile on the Internet social network 'MKM'
 */
@interface MKMProfileManager : NSObject

@property (weak, nonatomic) id<MKMProfileDataSource> dataSource;
@property (weak, nonatomic) id<MKMProfileDelegate> delegate;;

+ (instancetype)sharedInstance;

- (MKMProfile *)profileForID:(const MKMID *)ID;
- (void)setProfile:(MKMProfile *)profile forID:(const MKMID *)ID;
- (void)sendProfileForID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
