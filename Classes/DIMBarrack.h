//
//  DIMBarrack.h
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCore.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMBarrack : NSObject <MKMEntityDelegate, MKMProfileDataSource>

@property (weak, nonatomic) id<MKMEntityDelegate> entityDelegate;
@property (weak, nonatomic) id<MKMProfileDataSource> profileDataSource;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
