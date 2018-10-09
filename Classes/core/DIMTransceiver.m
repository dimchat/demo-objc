//
//  DIMTransceiver.m
//  DIM
//
//  Created by Albert Moky on 2018/10/7.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMUser.h"
#import "DIMContact.h"
#import "DIMGroup.h"

#import "DIMInstantMessage.h"

#import "DIMTransceiver.h"

@interface DIMTransceiver () {
    
    MKMEntityManager *_entityMamager;
    
    MKMAccountHistoryDelegate *_accountDelegate;
    MKMGroupHistoryDelegate *_groupDelegate;
}

@end

@implementation DIMTransceiver

static DIMTransceiver *s_sharedInstance = nil;

+ (instancetype)sharedInstance {
    if (!s_sharedInstance) {
        s_sharedInstance = [[self alloc] init];
    }
    return s_sharedInstance;
}

+ (instancetype)alloc {
    NSAssert(!s_sharedInstance, @"Attempted to allocate a second instance of a singleton.");
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
        _entityMamager = [MKMEntityManager sharedManager];
        
        _accountDelegate = [[MKMAccountHistoryDelegate alloc] init];
        _groupDelegate = [[MKMGroupHistoryDelegate alloc] init];
    }
    return self;
}

- (DIMUser *)userFromID:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Main, @"address.network error");
    const MKMMeta *meta = [_entityMamager metaWithID:ID];
    const MKMHistory *history = [_entityMamager historyWithID:ID];
    DIMUser *user = [[DIMUser alloc] initWithID:ID meta:meta];
    user.historyDelegate = _accountDelegate;
    [user runHistory:history];
    if (user.status != MKMAccountStatusRegistered) {
        NSAssert(false, @"contact.status error");
        return nil;
    }
    return user;
}

- (DIMContact *)contactFromID:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Main, @"address.network error");
    const MKMMeta *meta = [_entityMamager metaWithID:ID];
    const MKMHistory *history = [_entityMamager historyWithID:ID];
    DIMContact *contact = [[DIMContact alloc] initWithID:ID meta:meta];
    contact.historyDelegate = _accountDelegate;
    [contact runHistory:history];
    if (contact.status != MKMAccountStatusRegistered) {
        NSAssert(false, @"contact.status error");
        return nil;
    }
    return contact;
}

- (DIMGroup *)groupFromID:(const MKMID *)ID {
    NSAssert(ID.address.network == MKMNetwork_Group, @"address.network error");
    const MKMMeta *meta = [_entityMamager metaWithID:ID];
    const MKMHistory *history = [_entityMamager historyWithID:ID];
    DIMGroup *group = [[DIMGroup alloc] initWithID:ID meta:meta];
    group.historyDelegate = _groupDelegate;
    [group runHistory:history];
    if (group.members.count == 0) {
        NSAssert(false, @"group.members error");
        return nil;
    }
    return group;
}

#pragma mark - prepare message for sending out

- (DIMCertifiedMessage *)certifiedMessageWithContent:(const DIMMessageContent *)content
                                              sender:(const MKMID *)sender
                                            receiver:(const MKMID *)receiver {
    DIMEnvelope *env;
    env = [[DIMEnvelope alloc] initWithSender:sender receiver:receiver];
    return [self certifiedMessageWithContent:content envelope:env];
}

- (DIMCertifiedMessage *)certifiedMessageWithContent:(const DIMMessageContent *)content
                                            envelope:(const DIMEnvelope *)env {
    DIMInstantMessage *iMsg;
    iMsg = [[DIMInstantMessage alloc] initWithContent:content envelope:env];
    return [self certifiedMessageWithInstantMessage:iMsg];
}

- (DIMCertifiedMessage *)certifiedMessageWithInstantMessage:(const DIMInstantMessage *)message {
    // envelope
    const DIMInstantMessage *iMsg = message;
    const DIMEnvelope *env = iMsg.envelope;
    
    // 1. encrypt to secure message by receiver
    DIMSecureMessage *sMsg = nil;
    const MKMID *receiver = env.receiver;
    if (receiver.address.network == MKMNetwork_Main) {
        // receiver is a contact
        DIMContact *contact = [self contactFromID:receiver];
        sMsg = [contact encryptMessage:iMsg];
    } else if (receiver.address.network == MKMNetwork_Group) {
        // receiver is a group
        DIMGroup *group = [self groupFromID:receiver];
        sMsg = [group encryptMessage:iMsg];
    } else {
        NSAssert(false, @"receiver error");
        return nil;
    }
    
    // 2. sign to certified message by sender
    DIMCertifiedMessage *cMsg = nil;
    const MKMID *sender = env.sender;
    if (sender.address.network == MKMNetwork_Main) {
        DIMUser *user = [self userFromID:sender];
        // sign by sender
        cMsg = [user signMessage:sMsg];;
    } else {
        NSAssert(false, @"sender error");
        return nil;
    }
    
    return cMsg;
}

- (DIMMessageContent *)contentFromCertifiedMessage:(const DIMCertifiedMessage *)message {
    const DIMInstantMessage *iMsg;
    iMsg = [self instantMessageFromCertifiedMessage:message];
    DIMMessageContent *content = [iMsg.content copy];
    return content;
}

- (DIMInstantMessage *)instantMessageFromCertifiedMessage:(const DIMCertifiedMessage *)message {
    // envelope
    const DIMCertifiedMessage *cMsg = message;
    const DIMEnvelope *env = cMsg.envelope;
    
    // 1. verify to secure message by sender
    DIMSecureMessage *sMsg = nil;
    const MKMID *sender = env.sender;
    if (sender.address.network == MKMNetwork_Main) {
        DIMContact *contact = [self contactFromID:sender];
        sMsg = [contact verifyMessage:message];
    } else {
        NSAssert(false, @"sender error");
        return nil;
    }
    
    // 2. decrypt to instant message by receiver
    DIMInstantMessage *iMsg = nil;
    const MKMID *receiver = env.receiver;
    if (receiver.address.network == MKMNetwork_Main) {
        DIMUser *user = [self userFromID:receiver];
        iMsg = [user decryptMessage:sMsg];
    } else {
        NSAssert(false, @"receiver error");
        return nil;
    }
    
    return iMsg;
}

@end
