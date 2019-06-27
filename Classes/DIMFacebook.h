//
//  DIMFacebook.h
//  DIMClient
//
//  Created by Albert Moky on 2019/6/26.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

#define DIMMetaForID(ID)         [[DIMFacebook sharedInstance] metaForID:(ID)]
#define DIMProfileForID(ID)      [[DIMFacebook sharedInstance] profileForID:(ID)]

#define DIMAccountWithID(ID)     [[DIMFacebook sharedInstance] accountWithID:(ID)]
#define DIMUserWithID(ID)        [[DIMFacebook sharedInstance] userWithID:(ID)]
#define DIMGroupWithID(ID)       [[DIMFacebook sharedInstance] groupWithID:(ID)]

@interface DIMFacebook : DIMBarrack <DIMBarrackDelegate>

+ (instancetype)sharedInstance;

- (BOOL)verifyProfile:(DIMProfile *)profile;

@end

NS_ASSUME_NONNULL_END
