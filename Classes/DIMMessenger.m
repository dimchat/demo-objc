//
//  DIMMessenger.m
//  DIMClient
//
//  Created by Albert Moky on 2019/8/6.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "DIMFacebook+Storage.h"
#import "DIMKeyStore.h"

#import "DIMMessenger.h"

@implementation DIMMessenger

SingletonImplementations(DIMMessenger, sharedInstance)

- (instancetype)init {
    if (self = [super init]) {
        // register all content classes
        [DIMContent loadContentClasses];
        
        // delegates
        _barrack = [DIMFacebook sharedInstance];
        _keyCache = [DIMKeyStore sharedInstance];
    }
    return self;
}

- (DIMInstantMessage *)verifyAndDecryptMessage:(DIMReliableMessage *)rMsg {
    // 0. [Meta Protocol] check meta in first contact message
    DIMID *sender = [_barrack IDWithString:rMsg.envelope.sender];
    DIMMeta *meta = [_barrack metaForID:sender];
    if (!meta) {
        // first contact, try meta in message package
        meta = MKMMetaFromDictionary(rMsg.meta);
        if (!meta) {
            // TODO: query meta for sender from DIM network
            NSAssert(false, @"failed to get meta for sender: %@", sender);
            return nil;
        }
        NSAssert([meta matchID:sender], @"meta not match: %@, %@", sender, meta);
        DIMFacebook *facebook = [DIMFacebook sharedInstance];
        if (![facebook saveMeta:meta forID:sender]) {
            NSAssert(false, @"save meta error: %@, %@", sender, meta);
            return nil;
        }
    }
    
    // 1. verify and decrypt
    DIMInstantMessage *iMsg = [super verifyAndDecryptMessage:rMsg];
    
    // 2. check: top-secret message
    if (iMsg.delegate == nil) {
        iMsg.delegate = self;
    }
    NSAssert(iMsg.content, @"content cannot be empty");
    if (iMsg.content.type == DKDContentType_Forward) {
        // do it again to drop the wrapper,
        // the secret inside the content is the real message
        DIMForwardContent *content = (DIMForwardContent *)iMsg.content;
        rMsg = content.forwardMessage;
        
        DIMInstantMessage *secret = [self verifyAndDecryptMessage:rMsg];
        if (secret) {
            return secret;
        }
        // FIXME: not for you?
    }
    
    return iMsg;
}

@end
