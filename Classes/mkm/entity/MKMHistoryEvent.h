//
//  MKMHistoryEvent.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark history.events.operation

/**
 *  history.events.operation
 *
 *      data format: {
 *          operate: "register",
 *          time: 123,
 *          ...
 *      }
 */
@interface MKMHistoryOperation : MKMDictionary

@property (readonly, strong, nonatomic) NSString *operate;
@property (readonly, strong, nonatomic) NSDate *time;

+ (instancetype)operationWithOperation:(id)op;

/**
 *  Copy history operation
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithOperate:(const NSString *)op;

- (instancetype)initWithOperate:(const NSString *)op
                           time:(const NSDate *)time;

- (void)setExtraInfo:(id)info forKey:(NSString *)key;
- (nullable id)extraInfoForKey:(NSString *)key;

@end

#pragma mark - history.events

/**
 *  history.events
 *
 *      data format: {
 *          operation: "{...}",
 *          commander: "moky@address", // user ID
 *          signature: "..." // algorithm defined by version
 *      }
 */
@interface MKMHistoryEvent : MKMDictionary

@property (readonly, strong, nonatomic) MKMHistoryOperation *operation;

@property (readonly, strong, nonatomic) MKMID *commander;
@property (readonly, strong, nonatomic) NSData *signature;

+ (instancetype)eventWithEvent:(id)event;

/**
 *  Copy history event
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 Initialize an operation without signature,
 while the commander is the recorder

 @param op - operation object
 @return Event object
 */
- (instancetype)initWithOperation:(const MKMHistoryOperation *)op;

/**
 Initialize an operation with signature

 @param operation - JsON string of an operation
 @param ID - commander ID
 @param CT - signature
 @return Event object
 */
- (instancetype)initWithOperation:(const NSString *)operation
                        commander:(const MKMID *)ID
                        signature:(const NSData *)CT;

@end

NS_ASSUME_NONNULL_END
