//
//  DIMReceiptCommand.h
//  DIMClient
//
//  Created by Albert Moky on 2019/3/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMReceiptCommand : DIMCommand

@property (readonly, strong, nonatomic) NSString *message;

// original message info
@property (strong, nonatomic, nullable) DIMEnvelope *envelope;
@property (strong, nonatomic, nullable) NSData *signature;

/**
 *  Command message: {
 *      type : 0x88,
 *      sn   : 123,  // the same serial number with the original message
 *
 *      command : "receipt",
 *      message : "...",
 *      // -- extra info
 *      sender    : "...",
 *      receiver  : "...",
 *      time      : 0,
 *      signature : "..." // the same signature with the original message
 *  }
 */
- (instancetype)initWithMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
