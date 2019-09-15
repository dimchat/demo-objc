//
//  DIMAddressNameTable.h
//  DIMClient
//
//  Created by Albert Moky on 2019/9/13.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMAddressNameTable : DIMStorage

- (BOOL)saveRecord:(DIMID *)ID forName:(NSString *)name;

- (DIMID *)recordForName:(NSString *)name;

- (NSArray<DIMID *> *)namesWithRecord:(NSString *)ID;

@end

NS_ASSUME_NONNULL_END
