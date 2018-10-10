//
//  DIMCore.m
//  DIM
//
//  Created by Albert Moky on 2018/10/1.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMCore.h"

NSString *dimCoreVersion() {
    NSString *name = @"DIMCore";
    NSString *lang = @"ObjC";
    int major = (DIM_CORE_VERSION >> 16) & 0x0000FF;
    int minor = (DIM_CORE_VERSION >>  8) & 0x0000FF;
    int rev   = (DIM_CORE_VERSION >>  0) & 0x0000FF;
    
    return [NSString stringWithFormat:@"%@-%@ version %d.%d.%d", name, lang, major, minor, rev];
}
