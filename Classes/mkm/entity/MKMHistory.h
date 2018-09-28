//
//  MKMHistory.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKMArray.h"
#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMHistoryEvent;

/**
 *  history record item
 *
 *      data format: {
 *          events: [],
 *          merkle: "...", // merkle root of events, sha256
 *          signature: "..." // algorithm defined by version
 *      }
 */
@interface MKMHistoryRecord : MKMDictionary

@property (readonly, strong, nonatomic) const NSArray *events;
@property (readonly, strong, nonatomic) const NSData *merkleRoot;
@property (readonly, strong, nonatomic) const NSData *signature;

/**
 *  Copy history record from JsON String(dictionary)
 */
- (instancetype)initWithJSONString:(const NSString *)jsonString;
- (instancetype)initWithHistoryInfo:(const NSDictionary *)info;

/**
 Copy history record from network
 
 @param events - array of event string
 @param hash - merkle root of events
 @param CT - signature of the merkle root
 @return Record object
 */
- (instancetype)initWithEvents:(const NSArray *)events
                        merkle:(const NSData *)hash
                     signature:(const NSData *)CT;

- (void)addEvent:(const MKMHistoryEvent *)event;

/**
 sign(merkle + prev, SK)

 @param prev - merkle root of previous item's events
 @param SK - private key
 @return signature
 */
- (NSString *)signWithPreviousMerkle:(const NSData *)prev
                          privateKey:(const MKMPrivateKey *)SK;

/**
 verify(merkle + prev, signature, PK)

 @param prev - merkle root of previous item's events
 @param PK - public key
 @return YES/NO
 */
- (BOOL)verifyWithPreviousMerkle:(const NSData *)prev
                       publicKey:(const MKMPublicKey *)PK;

@end

@interface MKMHistory : MKMArray

/**
 *  Copy history data from JsON String(array)
 */
- (instancetype)initWithJSONString:(const NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
