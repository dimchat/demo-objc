//
//  DIMC.m
//  DIM
//
//  Created by Albert Moky on 2018/10/12.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMC.h"

NSString *dimcVersion() {
    NSString *name = @"DIMClient";
    NSString *lang = @"ObjC";
    int major = (DIMC_VERSION >> 16) & 0x0000FF;
    int minor = (DIMC_VERSION >>  8) & 0x0000FF;
    int rev   = (DIMC_VERSION >>  0) & 0x0000FF;
    
    return [NSString stringWithFormat:@"%@-%@ version %d.%d.%d", name, lang, major, minor, rev];
}
