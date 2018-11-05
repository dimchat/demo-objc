//
//  MKMHistoryBlock.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/5.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPublicKey;
@class MKMPrivateKey;

@class MKMID;

@class MKMHistoryTransaction;

/**
 *  history.records[i]
 *
 *      data format: {
 *          events: [],      // transactions
 *          merkle: "...",   // merkle root of events with SHA256D
 *          signature: "..." // algorithm defined by version
 *      }
 */
@interface MKMHistoryBlock : MKMDictionary

@property (readonly, strong, nonatomic) NSArray *transactions; // events
@property (readonly, strong, nonatomic) NSData *merkleRoot;
@property (readonly, strong, nonatomic) NSData *signature;
@property (readonly, strong, nonatomic) MKMID *recorder;

+ (instancetype)blockWithBlock:(id)record;

/**
 Copy history record from a dictionary

 @param dict - data from database/network
 @return history record(block)
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 Copy history record from network
 
 @param events - transactions with string items
 @param hash - merkle root of events
 @param CT - signature of the merkle root
 @param ID - recorder ID
 @return Record object
 */
- (instancetype)initWithTransactions:(const NSArray *)events
                              merkle:(const NSData *)hash
                           signature:(const NSData *)CT
                            recorder:(nullable const MKMID *)ID;

/**
 Add history event(Transaction) to this record(Block)

 @param event - Transaction
 */
- (void)addTransaction:(const MKMHistoryTransaction *)event;

@end

#pragma mark - Link Block

@interface MKMHistoryBlock (Link)

@property (readonly, strong, nonatomic) NSData *previousSignature;

@end

NS_ASSUME_NONNULL_END
