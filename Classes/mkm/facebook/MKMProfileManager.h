//
//  MKMProfileManager.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/10/10.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define MKMFacebook()       [MKMProfileManager sharedInstance]

#define MKMProfileForID(ID) [MKMFacebook() profileForID:(ID)]
#define MKMMemoForID(ID)    [MKMFacebook() memoForID:(ID)]

@class MKMID;

@class MKMProfile;
@class MKMMemo;

@protocol MKMProfileDataSource <NSObject>

- (MKMProfile *)profileForID:(const MKMID *)ID;

- (MKMMemo *)memoForID:(const MKMID *)ID;

@end

/**
 *  Profile Manager
 *
 *      To look up someone's profile on the Internet social network 'MKM'
 */
@interface MKMProfileManager : NSObject <MKMProfileDataSource>

@property (weak, nonatomic) id<MKMProfileDataSource> dataSource;

+ (instancetype)sharedInstance;

- (void)setProfile:(MKMProfile *)profile forID:(const MKMID *)ID;

- (void)setMemo:(MKMMemo *)memo forID:(const MKMID *)ID;

- (void)reduceMemory; // remove 1/2 objects

@end

//@class MKMID;
//@class MKMProfile;
//
//@protocol MKMProfileDelegate <NSObject>
//
//// send
//- (void)entityID:(const MKMID *)ID sendProfile:(const MKMProfile *)profile;
//
//// receive
//- (void)entityID:(const MKMID *)ID didReceiveProfile:(const MKMProfile *)profile;
//
//@end

NS_ASSUME_NONNULL_END
