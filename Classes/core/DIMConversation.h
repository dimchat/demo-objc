//
//  DIMConversation.h
//  DIM
//
//  Created by Albert Moky on 2018/10/9.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, DIMConversationID) {
    DIMConversationPersonal = MKMNetwork_Main,  // 0000 1000
    DIMConversationGroup    = MKMNetwork_Group, // 0001 0000
};
typedef UInt8 DIMConversationType;

@protocol DIMConversationDataSource;
@protocol DIMConversationDelegate;

@interface DIMConversation : NSObject

@property (readonly, nonatomic) DIMConversationType type; // Network ID

@property (readonly, strong, nonatomic) MKMID *ID;
@property (readonly, strong, nonatomic) NSString *title;

@property (weak, nonatomic) id<DIMConversationDataSource> dataSource;
@property (weak, nonatomic) id<DIMConversationDelegate> delegate;

- (instancetype)initWithEntity:(const MKMEntity *)entity
NS_DESIGNATED_INITIALIZER;

#pragma mark - Read

/**
 Get message count

 @return total count
 */
- (NSInteger)numberOfMessage;

/**
 Get message at index

 @param index - start from 0, latest first
 @return instant message
 */
- (DIMInstantMessage *)messageAtIndex:(NSInteger)index;

#pragma mark - Write

- (void)insertMessage:(const DIMInstantMessage *)iMsg;

/**
 Delete the message

 @param iMsg - instant message
 */
- (void)removeMessage:(const DIMInstantMessage *)iMsg;

/**
 Try to withdraw the message

 @param iMsg - instant message
 */
- (void)withdrawMessage:(const DIMInstantMessage *)iMsg;

@end

NS_ASSUME_NONNULL_END
