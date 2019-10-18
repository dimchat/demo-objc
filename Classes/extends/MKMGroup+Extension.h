//
//  MKMGroup+Extension.h
//  DIMCore
//
//  Created by Albert Moky on 2019/3/18.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <MingKeMing/MingKeMing.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKMGroup (Extension)

@property (readonly, copy, nonatomic) NSArray<MKMID *> *assistants;

- (BOOL)isFounder:(MKMID *)ID;

- (BOOL)isOwner:(MKMID *)ID;

- (BOOL)existsAssistant:(MKMID *)ID;

- (BOOL)existsMember:(MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
