//
//  MingKeMing.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NSString *mkmVersion() {
    NSString *name = @"MingKeMing";
    NSString *lang = @"ObjC";
    int major = (MKM_VERSION >> 16) & 0x0000FF;
    int minor = (MKM_VERSION >>  8) & 0x0000FF;
    int rev   = (MKM_VERSION >>  0) & 0x0000FF;
    
    return [NSString stringWithFormat:@"%@-%@ version %d.%d.%d", name, lang, major, minor, rev];
}
