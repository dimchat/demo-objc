//
//  DKDMessageContent+Quote.h
//  DaoKeDao
//
//  Created by Albert Moky on 2018/11/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DKDMessageContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface DKDMessageContent (Quote)

// SerialNumber for referenced reply in group chatting
@property (readonly, nonatomic) NSUInteger quoteNumber;

/**
 *  Quote text message: {
 *      type : 0x37,
 *      sn   : 456,
 *
 *      text  : "...",
 *      quote : 123   // referenced serial number of previous message
 *  }
 */
- (instancetype)initWithText:(const NSString *)text quote:(NSUInteger)sn;

@end

NS_ASSUME_NONNULL_END
