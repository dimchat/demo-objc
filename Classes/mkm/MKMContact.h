//
//  MKMContact.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/28.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAccount.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMContact : MKMAccount

@end

#pragma mark - Contact Delegate

@protocol MKMContactDelegate <NSObject>

- (MKMContact *)contactWithID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
