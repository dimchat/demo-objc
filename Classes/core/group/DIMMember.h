//
//  DIMMember.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/5.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMMember.h"

NS_ASSUME_NONNULL_BEGIN

#define DIMMemberWithID(ID, gID)  (DIMMember *)MKMMemberWithID(ID, gID)

@interface DIMMember : MKMMember

@end

NS_ASSUME_NONNULL_END
