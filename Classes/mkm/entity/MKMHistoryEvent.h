//
//  MKMHistoryEvent.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

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

@property (readonly, strong, nonatomic) const NSString *operate;
@property (readonly, strong, nonatomic) const NSDate *time;

/**
 *  Copy history operation from JsON String(dictionary)
 */
- (instancetype)initWithJSONString:(const NSString *)jsonString;
- (instancetype)initWithOperationInfo:(const NSDictionary *)info;

- (instancetype)initWithOperate:(const NSString *)op;
- (instancetype)initWithOperate:(const NSString *)op
                           time:(const NSDate *)time;

- (void)setExtraValue:(id)value forKey:(NSString *)key;

@end

/**
 *  history.events
 *
 *      data format: {
 *          operation: "{...}",
 *          operator: "moky@address", // user ID
 *          signature: "..." // algorithm defined by version
 *      }
 */
@interface MKMHistoryEvent : MKMDictionary

@property (readonly, strong, nonatomic) const MKMHistoryOperation *operation;

@property (readonly, strong, nonatomic) const MKMID *operatorID;
@property (readonly, strong, nonatomic) const NSData *signature;

/**
 *  Copy history event from JsON String(dictionary)
 */
- (instancetype)initWithJSONString:(const NSString *)jsonString;
- (instancetype)initWithEventInfo:(const NSDictionary *)info;

/**
 Initialize an operation without signature,
 while the operator is the recorder

 @param op - operation object
 @return Event object
 */
- (instancetype)initWithOperation:(const MKMHistoryOperation *)op;

/**
 Initialize an operation with signature

 @param op - operation object
 @param ID - operator's ID
 @param CT - signature
 @return Event object
 */
- (instancetype)initWithOperation:(const MKMHistoryOperation *)op
                         operator:(const MKMID *)ID
                        signature:(const NSData *)CT;

@end

NS_ASSUME_NONNULL_END
