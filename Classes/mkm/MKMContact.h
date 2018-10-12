//
//  MKMContact.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAccount.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMContactMemo;

@interface MKMContact : MKMAccount {
    
    MKMContactMemo *_memo; // same keys to the profile
}

@property (readonly, strong, nonatomic) MKMContactMemo *memo;

@end

NS_ASSUME_NONNULL_END
