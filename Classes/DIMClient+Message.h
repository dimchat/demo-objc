//
//  DIMClient+Message.h
//  DIM
//
//  Created by Albert Moky on 2018/10/20.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMClient (Message)

/**
 Send message (secured + certified) to target station
 
 @param cMsg - certified message
 @return YES on success
 */
- (BOOL)sendMessage:(const DIMCertifiedMessage *)cMsg;

/**
 Save received message (secured + certified) from target station
 
 @param iMsg - instant message
 */
- (void)recvMessage:(const DIMInstantMessage *)iMsg;

@end

NS_ASSUME_NONNULL_END
