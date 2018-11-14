//
//  NSDate+Timestamp.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/15.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSDate+Timestamp.h"

NSNumber *NSNumberFromDate(const NSDate *date) {
    if (!date) {
        // today
        date = [[NSDate alloc] init];
    }
    NSTimeInterval ti = [date timeIntervalSince1970];
    return [[NSNumber alloc] initWithLong:ti];
}

NSDate *NSDateFromNumber(const NSNumber *timestamp) {
    if (!timestamp) {
        // today
        return [[NSDate alloc] init];
    }
    NSTimeInterval ti = [timestamp doubleValue];
    if (ti < 1) {
        return [[NSDate alloc] init];
    }
    return [[NSDate alloc] initWithTimeIntervalSince1970:ti];
}
