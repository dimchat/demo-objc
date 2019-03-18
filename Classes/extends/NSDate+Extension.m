//
//  NSDate+Extension.m
//  DIMClient
//
//  Created by Albert Moky on 2019/3/18.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Locale)

- (NSString *)descriptionWithLocale:(nullable id)locale {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.doesRelativeDateFormatting = YES;
    });
    if (locale) {
        dateFormatter.locale = locale;
    }
    return [dateFormatter stringFromDate:self];
}

@end

NSString *NSStringFromDate(const NSDate *date) {
    return [NSString stringWithFormat:@"%@", date];
}
