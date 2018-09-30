//
//  DIMCertifiedMessage.m
//  DIM
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018年 DIM Group. All rights reserved.
//

#import "DIMCertifiedMessage.h"

@interface DIMCertifiedMessage ()

@property (strong, nonatomic) const NSData *signature;

@end

@implementation DIMCertifiedMessage

- (instancetype)initWithContent:(const DIMMessageContent *)content
                         sender:(const MKMAccount *)from
                       receiver:(const MKMAccount *)to
                            key:(const MKMSymmetricKey *)key {
    const NSData *CT = nil;
    self = [self initWithContent:content
                          sender:from
                        receiver:to
                             key:key
                       signature:CT];
    return self;
}

- (instancetype)initWithContent:(const DIMMessageContent *)content
                         sender:(const MKMAccount *)from
                       receiver:(const MKMAccount *)to
                            key:(const MKMSymmetricKey *)key
                      signature:(const NSData *)CT {
    self = [super initWithContent:content
                           sender:from
                         receiver:to
                              key:key];
    if (self) {
        self.signature = CT;
    }
    return self;
}

@end
