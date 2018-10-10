//
//  DIMConversation.h
//  DIM
//
//  Created by Albert Moky on 2018/10/9.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MingKeMing.h"

NS_ASSUME_NONNULL_BEGIN

enum UInt8 {
    DIMConversationPersonal = MKMNetwork_Main,  // 0000 1000
    DIMConversationGroup    = MKMNetwork_Group, // 0001 0000
};
typedef MKMNetworkID DIMConversationType;

@interface DIMConversation : NSObject {
    
    // the latest message is in the first
    NSMutableArray<const DIMInstantMessage *> *_messages;
}

@property (readonly, nonatomic) DIMConversationType type;

@property (readonly, strong, nonatomic) MKMID *ID;
@property (readonly, strong, nonatomic) NSString *title;

- (instancetype)initWithEntity:(const MKMEntity *)entity
NS_DESIGNATED_INITIALIZER;

/**
 Insert an instant message into the list

 @param iMsg - instant message
 @return message position in the list, -1 on error
 */
- (NSInteger)insertInstantMessage:(const DIMInstantMessage *)iMsg;

@end

NS_ASSUME_NONNULL_END
