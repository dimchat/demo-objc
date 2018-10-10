//
//  MKMHistory.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMArray.h"
#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPublicKey;
@class MKMPrivateKey;

@class MKMID;
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
@property (readonly, strong, nonatomic) const MKMID *recorder;

+ (instancetype)recordWithRecord:(id)record;

/**
 *  Copy history record
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

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
/**
 Copy history record from network

 @param events - array of event string
 @param hash - merkle root of events
 @param CT - signature of the merkle root
 @param ID - recorder ID
 @return Record object
 */
- (instancetype)initWithEvents:(const NSArray *)events
                        merkle:(const NSData *)hash
                     signature:(const NSData *)CT
                      recorder:(nullable const MKMID *)ID;

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

+ (instancetype)historyWithHistory:(id)history;

@end

NS_ASSUME_NONNULL_END
